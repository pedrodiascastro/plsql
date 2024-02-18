SELECT username, account_status, created, lock_date, expiry_date
  FROM dba_users
 WHERE account_status != 'OPEN';

ALTER USER username ACCOUNT UNLOCK;
