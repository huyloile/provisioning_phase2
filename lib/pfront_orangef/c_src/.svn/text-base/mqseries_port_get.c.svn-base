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
  fprintf(stderr, "mqseries_port_get: ");
  perror(a);
  exit(1);
}

static void fail(char *a) {
  fprintf(stderr, "mqseries_port_get: %s\n", a);
  exit(1);
}

static int trace = 0;

#define TRACE(args) { if ( trace ) { fprintf(stderr, "MQ_Series_get: "); \
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

  TRACE((stderr, "Outgoing size get=%d %s\n", size, buf));
  do_write(fd, header, sizeof(header));
  do_write(fd, buf, size);
}

/**********************************************************************/

/**********************************************************************/

void terminate(char *msg) {
  
  fprintf(stderr, "mqseries_port_get terminating (%s)\n", msg);
  exit(0);
}


/* A buffer for Erlang marshalling. */
#define MAX_MESSAGE_SIZE 65536
static char rspbuf[MAX_MESSAGE_SIZE];

void reply_string(char *atom, char *str) {
  int sz=0;

  TRACE((stderr, "Sending {%s,%s}\n", atom, str));
  ei_encode_version(rspbuf, &sz);
  ei_encode_tuple_header(rspbuf, &sz, 2);
  ei_encode_atom(rspbuf, &sz, atom);
  ei_encode_string(rspbuf, &sz, str);
  msg_write(STDOUT_FILENO, rspbuf, sz);
} 

void reply_mq(char *atom, int returnvalue) {
  int sz=0;

  ei_encode_version(rspbuf, &sz);
  ei_encode_tuple_header(rspbuf, &sz, 2);
  ei_encode_atom(rspbuf, &sz, atom);
  ei_encode_long(rspbuf, &sz, returnvalue);
  msg_write(STDOUT_FILENO, rspbuf, sz);
}  

void binary_md(char *query, int *sz,char unsigned *mdelement, long size) {
  char result[size];
  char false[48];
  if ( ei_decode_atom(query, sz, false) ) {
     if ( !ei_decode_binary(query, sz, &result, &size) ) {
       TRACE((stderr,"decode binary ok %s\n",result));
       memcpy(mdelement,           /* character string format            */
	      &result, size);
     }
  };
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


void decode(char *query, MQMD *md, MQGMO *gmo) {
  int sz=0;
  int version=0;
  int r=0;
  int arity=0;
  r=ei_decode_version(query, &sz, &version);
  r=ei_decode_tuple_header(query, &sz, &arity);
  long_md(query,&sz,&(*gmo).WaitInterval);
  binary_md(query,&sz,(*md).CorrelId, 24);
}


void close_mq(MQHCONN Hcon,MQHOBJ Hobj,MQLONG C_options) {
  MQLONG CReason; 
  MQLONG CompCode;
  MQLONG Reason;
  MQCLOSE(Hcon,                    /* connection handle           */
	  &Hobj,                   /* object handle               */
	  C_options,
	  &CompCode,               /* completion code             */
	  &CReason);                /* reason code                 */
  /*Disconnect seems to be unuseful , but more clean*/ 
  MQDISC(&Hcon,                     /* connection handle          */
	 &CompCode,                 /* completion code            */
	 &Reason);                  /* reason code                */
  TRACE((stderr,"closed queue for get %ld %ld\n",CReason,Reason));
  exit(1);
}

/**********************************************************************/

int main(int argc, char *argv[]) {
  fd_set fds;
  int sz=0;
  char query[MAX_MESSAGE_SIZE];

   /*   Declare MQI structures needed                                */
  MQOD     od = {MQOD_DEFAULT};    /* Object Descriptor             */
  MQMD     md = {MQMD_DEFAULT};    /* Message Descriptor            */
  MQGMO   gmo = {MQGMO_DEFAULT};   /* put message options           */
  /** note, sample uses defaults where it can **/
  
  MQHCONN  Hcon;                   /* connection handle             */
  MQHOBJ   Hobj;                   /* object handle                 */
  MQLONG   O_options;              /* MQOPEN options                */
  MQLONG   C_options;              /* MQCLOSE options               */
  MQLONG   CompCode;               /* completion code               */
  MQLONG   OpenCode;               /* MQOPEN completion code        */
  MQLONG   Reason;                 /* reason code                   */
  MQLONG   CReason;                /* reason code for MQCONN        */
  MQBYTE   buffer[601];            /* message buffer                */
  MQLONG   buflen;                 /* buffer length                 */
  MQLONG   messlen;                /* message length received       */
  char     QMName[50];             /* queue manager name            */
  
  C_options = MQCO_NONE; 
  
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
   strcpy(od.ObjectName, argv[1]);
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
   if (CompCode == MQCC_FAILED) {
     fprintf (stderr,"MQSERIES GET: MQCONN ended error open %ld",CReason);
     reply_mq("error", CReason);
     exit( (int)Reason);
   }

   if (argc > 3) {
     O_options = atoi( argv[3] );
   }
   else
   {
     O_options = MQOO_INPUT_AS_Q_DEF           /* open queue for input     */
               | MQOO_FAIL_IF_QUIESCING /* but not if MQM stopping   */
               ;                        /* = 0x2001 = 8193 decimal   */
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
     fprintf (stderr,"MQSERIES GET: unable to open queue for output %ld",Reason);
     reply_mq("error", Reason);
     exit( (int) Reason);
   }
  /******************************************************************/
   /*                                                                */
   /*   Read lines from the file and get the message from the queue   */
   /*   Loop until null line or end of file, or there is a failure   */
   /*                                                                */
   /******************************************************************/
   CompCode = OpenCode;        /* use MQOPEN result for initial test */
   gmo.Options = MQGMO_WAIT       /* wait for new messages           */
               + MQGMO_CONVERT    /* convert if necessary            */
               + MQGMO_ACCEPT_TRUNCATED_MSG;   /*truncated message */
   gmo.WaitInterval = 3000;      /*  3000 millisecond limit for waiting and loop     */

   ei_encode_version(rspbuf, &sz);
   ei_encode_string(rspbuf, &sz, "ok");
   msg_write(STDOUT_FILENO, rspbuf, sz);

   while ( 1 ) {
    memcpy(md.MsgId, MQMI_NONE, sizeof(md.MsgId));
    memcpy(md.CorrelId, MQCI_NONE, sizeof(md.CorrelId));
    md.Encoding       = MQENC_NATIVE;
    md.CodedCharSetId = MQCCSI_Q_MGR;
    FD_ZERO(&fds);
    FD_SET(STDIN_FILENO, &fds);
    buflen = sizeof(buffer) - 1; /* buffer size available for GET   */
    sz = msg_read(STDIN_FILENO, query, sizeof(query));
    if ( sz == 1 ) { 
      TRACE((stderr,"something in stdin\n"));
      close_mq(Hcon,Hobj,C_options);
      exit(0);
    }
    else {
      TRACE((stderr,"something in stdin : length %d\n",sz));
      decode(query,&md,&gmo);
    }
    TRACE((stderr,"after info from mqserver --%s-- --%s-- --%ld--\n",md.MsgId,md.CorrelId,gmo.WaitInterval));
    /****************************************************************/
    /* The following two statements are not required if the MQGMO   */
    /* version is set to MQGMO_VERSION_2 and and gmo.MatchOptions   */
    /* is set to MQGMO_NONE                                         */
    /****************************************************************/
    /*                                                              */
    /*   In order to read the messages in sequence, MsgId and       */
    /*   CorrelID must have the default value.  MQGET sets them     */
    /*   to the values in for message it returns, so re-initialise  */
    /*   them before every call                                     */
    /*                                                              */
    /****************************************************************/

    MQGET(Hcon,                /* connection handle                 */
	  Hobj,                /* object handle                     */
	  &md,                 /* message descriptor                */
	  &gmo,                /* get message options               */
	  buflen,              /* buffer length                     */
	  buffer,              /* message buffer                    */
	  &messlen,            /* message length                    */
	  &CompCode,           /* completion code                   */
	  &Reason);            /* reason code                       */

    TRACE((stderr,"MQGET ended with reason code %ld %ld\n", Reason,CompCode));
    if (CompCode != MQCC_OK) {
      if (Reason != MQRC_NO_MSG_AVAILABLE) {
	if (CompCode == MQCC_FAILED) {
	  fprintf(stderr, "MQ_Series get error: "); 
	  reply_mq("error", Reason);
	  close_mq(Hcon,Hobj,C_options);
	}
	else
	  reply_mq("warning", Reason);
	  close_mq(Hcon,Hobj,C_options);
      };
    }
    else {
      TRACE((stderr,"MQGET compcode diff from MQCC_ok %ld %ld\n", Reason,CompCode));
      /* All is ok ---> send message */
      buffer[messlen] = '\0';            /* add terminator          */
      reply_string("get", buffer);
    };
  }
}

