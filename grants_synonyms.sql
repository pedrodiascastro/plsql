select 'GRANT '||privilege||' ON '||TABLE_NAME||' TO WERBHV;' from user_tab_privs_recd;
SELECT 'CREATE OR REPLACE SYNONYM '||SYNONYM_NAME||' FOR '||TABLE_OWNER||'.'||TABLE_NAME||';' FROM user_synonyms WHERE TABLE_OWNER = 'VENC';
