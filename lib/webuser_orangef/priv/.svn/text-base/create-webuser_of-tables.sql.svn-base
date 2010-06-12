
-- Specific information for Orange France webuser history / stats feature
CREATE TABLE webuser_of_logs
       (login CHAR(10) NOT NULL,             -- representative login
        uid INT4 NOT NULL,                   -- customer concerned by entry
        unixtime INT4 NOT NULL,              -- timestamp
        action INT1 NOT NULL,                -- action code 1: consult_user
                                             --             2: consult_session
                                             --             3: update 
        details VARCHAR(32) DEFAULT NULL,    -- info related to action
        INDEX  logs_by_uid (uid),
        INDEX  logs_by_action (action),
        INDEX  logs_by_login (login)
        );
