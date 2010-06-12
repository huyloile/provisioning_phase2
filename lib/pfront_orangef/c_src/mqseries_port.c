#include <sys/time.h>
#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#include <ei.h>
#include <ei_connect.h>

    /* includes for MQI */
#include <cmqc.h>

#define HDRSIZE 4
/**********************************************************************/

static void fatal(char *a) {
  fprintf(stderr, "mqseries_port_put: ");
  perror(a);
  exit(1);
}

static void fail(char *a) {
  fprintf(stderr, "mqseries_port_put: %s\n", a);
  exit(1);
}

static int trace = 0;

#define TRACE(args) { if ( trace ) { fprintf(stderr, "MQ_Series: "); \
                                     fprintf args; } }

/**********************************************************************/

/* Read exactly n bytes. */

void do_read(int fd, char *buf, int n) {
  while ( n ) {
    int nr = read(fd, buf, n);
    if ( nr < 0 ) fatal("read");
    if ( nr == 0 ) fail("read: EOF");
    buf += nr;
    n -= nr;
  }
}

/* Write exactly n bytes. */

void do_write(int fd, char *buf, int n) {
  while ( n ) {
    int nw =  write(fd, buf, n);
    if ( nw < 0 ) fatal("write");
    if ( nw == 0 ) fail("write: EOF");
    buf += nw;
    n -= nw;
  }
}

/**********************************************************************/

/* Read an Erlang message. Return its size. */

int msg_read(int fd, char *buf, int buffsize) {
  int size;

  do_read(fd, buf, HDRSIZE);
  size = 
    ( ((int)buf[0]&255) << 24 ) |
    ( ((int)buf[1]&255) << 16 ) |
    ( ((int)buf[2]&255) << 8  ) |
    ( ((int)buf[3]&255)       );

  TRACE((stderr, "Incoming size=%d\n", size));
  if ( size > buffsize ) fail("Message too big");
  do_read(fd, buf, size);
  return size;
}

/* Write an Erlang message. */

void msg_write(int fd, char *buf, int size) {
  char header[HDRSIZE];

  header[0] = size >> 24;
  header[1] = size >> 16;
  header[2] = size >> 8;
  header[3] = size;

  TRACE((stderr, "Outgoing size put=%d %s\n", size, buf));
  do_write(fd, header, sizeof(header));
  do_write(fd, buf, size);
}

/**********************************************************************/

/**********************************************************************/

void close_mq(MQHCONN Hcon,MQHOBJ Hobj,MQLONG O_options) {
  MQLONG CReason; 
  MQLONG CompCode;
  MQLONG Reason;
  MQCLOSE(Hcon,                    /* connection handle           */
	  &Hobj,                   /* object handle               */
	  O_options,
	  &CompCode,               /* completion code             */
	  &CReason);                /* reason code                 */
  /*Disconnect seems to be unuseful , but more clean*/ 
  MQDISC(&Hcon,                     /* connection handle          */
	 &CompCode,                 /* completion code            */
	 &Reason);                  /* reason code                */
  TRACE((stderr,"closed queue for get %ld %ld\n",CReason,Reason));
}

void terminate(char *msg,MQHCONN Hcon,MQHOBJ Hobj,MQLONG O_options) {
  fprintf(stderr, "mqseries put terminating : (%s)\n", msg);
  close_mq(Hcon,Hobj,O_options);
  exit(1);
}

/**********************************************************************/

/* A buffer for Erlang marshalling. */
#define MAX_MESSAGE_SIZE 65536
static char rspbuf[MAX_MESSAGE_SIZE];

void reply_mq(char *atom, int returnvalue) {
  int sz=0;

  ei_encode_version(rspbuf, &sz);
  ei_encode_tuple_header(rspbuf, &sz, 2);
  ei_encode_atom(rspbuf, &sz, atom);
  ei_encode_long(rspbuf, &sz, returnvalue);
  msg_write(STDOUT_FILENO, rspbuf, sz);
} 

void reply_mq_ok(char *atom, int returnvalue, char *id) {
  int sz=0;

  ei_encode_version(rspbuf, &sz);
  ei_encode_tuple_header(rspbuf, &sz, 3);
  ei_encode_atom(rspbuf, &sz, atom);
  ei_encode_long(rspbuf, &sz, returnvalue);
  ei_encode_binary(rspbuf, &sz, id, 24);
  msg_write(STDOUT_FILENO, rspbuf, sz);
}  

void long_md(char *query, int *sz,long *mdelement) {
  long result;
  char false[48];
  if ( ei_decode_atom(query, sz, false) ) { 
     if ( !ei_decode_long(query, sz,&result) ) {
       memcpy(mdelement,           /* character string format            */
	      &result, sizeof(mdelement));
     }
  };
}

void binary_md(char *query, int *sz,char unsigned *mdelement, long size) {
  char result[size];
  char false[48];
  if ( ei_decode_atom(query, sz, false) ) { 
     if ( !ei_decode_binary(query, sz, &result, &size) ) {
       memcpy(mdelement,           /* character string format            */
	      &result, size);
     }
  };
}

void char_md(char *query, int *sz, char *mdelement , int size) {
  char result[48];   /* Max length inside structure md*/
    if ( ei_decode_atom(query, sz, result) ) {
      if ( !ei_decode_string(query,sz, result) ) {
	memcpy(mdelement,           /* character string format            */
	       result, size);
      }
    };
}
      
void copy_md(char *query, MQMD *md) {
  int sz=0;
  int version=0;
  int arity=0;
  int r=0;
  char result[48];
  
  r=ei_decode_version(query, &sz, &version);
  r=ei_decode_tuple_header(query, &sz, &arity);
  ei_decode_atom(query,&sz, result);     /* Decodage de l'en tête */
  
  char_md(query,&sz,(*md).StrucId,sizeof((*md).StrucId));
  
  long_md(query,&sz,&(*md).Version);
  long_md(query,&sz,&(*md).Report);
  long_md(query,&sz,&(*md).MsgType);
  long_md(query,&sz,&(*md).Expiry);
  long_md(query,&sz,&(*md).Feedback);
  long_md(query,&sz,&(*md).Encoding);
  long_md(query,&sz,&(*md).CodedCharSetId);
  
  char_md(query,&sz,(*md).Format,sizeof((*md).Format));
  
  long_md(query,&sz,&(*md).Priority);
  long_md(query,&sz,&(*md).Persistence);
  
  binary_md(query,&sz,(*md).MsgId, 24);
  binary_md(query,&sz,(*md).CorrelId, 24);
  
  long_md(query,&sz,&(*md).BackoutCount);
  
  char_md(query,&sz,(*md).ReplyToQ,sizeof((*md).ReplyToQ));
  char_md(query,&sz,(*md).ReplyToQMgr,sizeof((*md).ReplyToQMgr));
  char_md(query,&sz,(*md).UserIdentifier,sizeof((*md).UserIdentifier));
  char_md(query,&sz,(*md).AccountingToken, 32);
  char_md(query,&sz,(*md).ApplIdentityData,sizeof((*md).ApplIdentityData));
  
  long_md(query,&sz,&(*md).PutApplType);

  char_md(query,&sz,(*md).PutApplName,sizeof((*md).PutApplName));
  char_md(query,&sz,(*md).PutDate,sizeof((*md).PutDate));
  char_md(query,&sz,(*md).PutTime,sizeof((*md).PutTime));
  char_md(query,&sz,(*md).ApplOriginData,sizeof((*md).ApplOriginData));
  char_md(query,&sz,(*md).GroupId, 24);
  
  long_md(query,&sz,&(*md).MsgSeqNumber);
  long_md(query,&sz,&(*md).Offset);
  long_md(query,&sz,&(*md).MsgFlags);
  long_md(query,&sz,&(*md).OriginalLength);
  }

/**********************************************************************/

/* printf("%s", NULL) crashes on Solaris */

char *optnull(char *s) { return s ? s : "(null)"; }

int main(int argc, char *argv[]) {
  FILE *fp;
  int sz;
   /*   Declare MQI structures needed                                */
   MQOD     od = {MQOD_DEFAULT};    /* Object Descriptor             */
   MQMD     md = {MQMD_DEFAULT};    /* Message Descriptor            */
   MQPMO   pmo = {MQPMO_DEFAULT};   /* put message options           */
      /** note, sample uses defaults where it can **/

   MQHCONN  Hcon;                   /* connection handle             */
   MQHOBJ   Hobj;                   /* object handle                 */
   MQLONG   O_options;              /* MQOPEN options                */
   MQLONG   md_report;              /* md_report options               */
   MQLONG   CompCode;               /* completion code               */
   MQLONG   OpenCode;               /* MQOPEN completion code        */
   MQLONG   Reason;                 /* reason code                   */
   MQLONG   CReason;                /* reason code for MQCONN        */
   MQLONG   messlen;                /* message length                */
   char     QMName[50];             /* queue manager name            */


    char query[MAX_MESSAGE_SIZE];
    fd_set fds;

   TRACE((stderr,"start put with %d options\n", argc));
   if (argc < 2)
   {
     fprintf(stderr,"Required parameter missing - queue name\n");
     exit(99);
   }

   /* For debug */
  if ( argc>=2 && !strcmp(argv[1], "-d") ) {
     TRACE((stderr,"mod debug"));
    trace = 1;
    memmove(argv+1, argv+2, sizeof(argv[0])*(argc-2));
    --argc;
  }

   /******************************************************************/
   /*                                                                */
   /*   Connect to queue manager                                     */
   /*                                                                */
   /******************************************************************/
   QMName[0] = 0;    /* default */
   if (argc > 2)
     {
     TRACE((stderr,"Qname %s",argv[2]));
     strcpy(QMName, argv[2]);
     }
   MQCONN(QMName,                  /* queue manager                  */
          &Hcon,                   /* connection handle              */
          &CompCode,               /* completion code                */
          &CReason);               /* reason code                    */


   TRACE((stderr,"open %s",argv[2]));
   /* report reason and stop if it failed     */
   if (CompCode == MQCC_FAILED)
   { 
     reply_mq("error", CReason);
     fprintf (stderr,"MQCONN ended with reason %ld\n",CReason);
     exit( (int)CReason );
   }

   /******************************************************************/
   /*                                                                */
   /*   Use parameter as the name of the target queue                */
   /*                                                                */
   /******************************************************************/
   strncpy(od.ObjectName, argv[1], (size_t)MQ_Q_NAME_LENGTH);
   TRACE((stderr,"queue name %s",argv[1]));

   
   /******************************************************************/
   /*                                                                */
   /*   Open the target message queue for output                     */
   /*                                                                */
   /******************************************************************/

   if (argc > 3)
   {
     O_options = atoi( argv[3] );
   }
   else
   {
     O_options = MQOO_OUTPUT            /* open queue for output     */
               | MQOO_FAIL_IF_QUIESCING /* but not if MQM stopping   */          
       ;                        /* = 0x2010 = 8208 decimal   */
   }

   if (argc > 4) {
     pmo.Options = MQPMO_SET_IDENTITY_CONTEXT;
     memcpy(&(md.UserIdentifier), argv[4],sizeof(md.UserIdentifier));
   }

   TRACE((stderr,"option are %ld\n", O_options));
   MQOPEN(Hcon,                      /* connection handle            */
          &od,                       /* object descriptor for queue  */
          O_options,                 /* open options                 */
          &Hobj,                     /* object handle                */
          &OpenCode,                 /* MQOPEN completion code       */
          &Reason);                  /* reason code                  */

   /* report reason, if any; stop if failed      */
   if (Reason != MQRC_NONE)
     {
       TRACE((stderr,"MQOPEN ended with reason code %ld\n", Reason));
     }
   
   if (OpenCode == MQCC_FAILED)
   {
     fprintf (stderr,"unable to open queue for output with code %ld\n",Reason);
     reply_mq("error", Reason);
     exit( (int)Reason);
   }
   /******************************************************************/
   /*                                                                */
   /*   Read lines from the file and put them to the message queue   */
   /*   Loop until null line or end of file, or there is a failure   */
   /*                                                                */
   /******************************************************************/
   /* Default value */
   md_report =  MQRO_COPY_MSG_ID_TO_CORREL_ID;
   memcpy(&(md.Report), 
	  &md_report, sizeof(&(md.Report)) );

   memcpy(md.Format,           /* character string format            */
	   MQFMT_STRING, (size_t)MQ_FORMAT_LENGTH);


   /*   memcpy(&(md.ReplyToQ),argv[5],sizeof(&(md.ReplyToQ)));
   strncpy(md.ReplyToQ, argv[5],sizeof(md.ReplyToQ));
   TRACE((stderr,"reply to queue2 :%s\n", md.ReplyToQ)); */

   /*   TRACE((stderr,"size champssss %d\n valeur %s", sizeof(md.ReplyToQ),argv[5])); */
   fp = stdin;

   ei_encode_version(rspbuf, &sz);
   ei_encode_string(rspbuf, &sz, "ok");
   msg_write(STDOUT_FILENO, rspbuf, sz);

   /* reception of default structure */
   FD_ZERO(&fds);
   FD_SET(STDIN_FILENO, &fds);
   sz = msg_read(STDIN_FILENO, query, sizeof(query));
   
   copy_md(query,&md);
   /*   memcpy(&(md.ReplyToQ), argv[5],sizeof(md.ReplyToQ));
	TRACE((stderr,"reply to queue 1:%s\n", md.ReplyToQ)); */
   CompCode = OpenCode;        /* use MQOPEN result for initial test */

    while ( 1 ) {
      FD_ZERO(&fds);
      FD_SET(STDIN_FILENO, &fds);
      sz = msg_read(STDIN_FILENO, query, sizeof(query));
      TRACE((stderr,"receive info %s",query));
      if ( sz != 1 ) fail("Expected a 1-byte tag");
      switch ( *query ) {
      case 'E':
	messlen = msg_read(STDIN_FILENO, query, sizeof(query));
	
	/******************************************************************/
	/* Use these options when connecting to Queue Managers that also  */
	/* support them, see the Application Programming Reference for    */
	/* details.                                                       */
	/* These options cause the MsgId and CorrelId to be replaced, so  */
	/* that there is no need to reset them before each MQPUT          */
	/******************************************************************/
	if (query[messlen-1] == '\n')  /* last char is a new-line    */
	  {
	    query[messlen-1]  = '\0';    /* replace new-line with null */
	    --messlen;                    /* reduce buffer length       */
	 }
	
	/****************************************************************/
	/*                                                              */
	/*   Put each buffer to the message queue                       */
       /*                                                              */
	/****************************************************************/
	if (messlen > 0)
	  {
	    TRACE((stderr,"we get send message\n"));
	    /**************************************************************/
	    /* The following two statements are not required if the       */
	    /* MQPMO_NEW_MSG_ID and MQPMO_NEW _CORREL_ID options are used */
	    /**************************************************************/
	    memcpy(md.MsgId,           /*reset MsgId to get a new one   */
		   MQMI_NONE, sizeof(md.MsgId) );
		    
	    memcpy(md.CorrelId,         /*reset CorrelId to get a new one  */
		   MQCI_NONE, sizeof(md.CorrelId) );
	    
	    MQPUT(Hcon,                /* connection handle               */
		  Hobj,                /* object handle                   */
		  &md,                 /* message descriptor              */
		  &pmo,                /* default options (datagram)      */
		  messlen,             /* message length                  */
		  query,              /* message buffer                  */
		  &CompCode,           /* completion code                 */
		  &Reason);            /* reason code                     */
	    
	    TRACE((stderr,"MQPUT ended with reason code %ld\n", Reason));
	    if (CompCode != MQCC_OK)
	    {
	      if (CompCode == MQCC_FAILED)
		reply_mq("error", Reason);
	      else
		reply_mq("warning", Reason);
	    }
	    else {
	      TRACE((stderr,"MQPUT Id %s and Corellid %s\n",md.MsgId,md.CorrelId));
	      reply_mq_ok("put", Reason,md.MsgId);
	    }
	  }
	else   /* satisfy end condition when empty line is read */
	  {
	    CompCode = MQCC_FAILED;
	    Reason = -1;
	    reply_mq("error", Reason);
	  }
	break;
    case 'T':
      terminate("stop request",Hcon,Hobj,O_options);
      default:
	fprintf(stderr, "mqseries_port: Unknown command %d\n", *query);
	return 1;
      }
    }
    
   }
