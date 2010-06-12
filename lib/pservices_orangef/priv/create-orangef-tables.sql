
-- Specific information for Orange France clients.
CREATE TABLE users_orangef_extra
  (uid          INT4 NOT NULL, -- REFERENCES users(uid),
   tech_segment INT1 NOT NULL DEFAULT 0,
     -- Technological segment.
     -- The meaning of the constants can be found in pfront_orangef.app.src.
   commercial_segment VARCHAR(25) DEFAULT NULL,
     -- Commercial Segment returned by Spider in field offerPOrSUid
   nb_subs_ocf_failed INT2 DEFAULT 0,
   PRIMARY KEY (uid)
  );
