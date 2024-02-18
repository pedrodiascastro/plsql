select s.username, s.sid, s.serial#, s.inst_id, s.status,
       s.logon_time, s.blocking_session, s.final_blocking_session,
       s.osuser, s.machine, s.program, s.module, s.action, sa.sql_text
  from gv$session s
  left join gv$sqlarea sa
    on s.sql_address = sa.address
   and s.sql_hash_value = sa.hash_value
 where username is not null
 and sa.sql_text is not null
 order by blocking_session, sid, logon_time;

SELECT substr(to_char(c.LOCKWAIT),1,8) lockwait
,b.inst_id
,substr(to_char(b.session_id)||','||to_char(c.serial#),1,12) sid_serial#
  ,c.STATUS
  ,rpad(c.osuser,8) unix
  ,rpad(c.username,8) ora
  ,to_char(c.logon_time,'dd/mm hh24:mi:ss') logon_time
  ,sql_exec_start
  ,prev_exec_start
  ,a.object_name Tabela
  ,decode(b.locked_mode,1,'No Lock',
    2,'Row Share',
    3,'Row Exclusive',
    4,'Share',
    5,'Share Row Excl',
    6,'Exclusive',NULL) Status_Lock
  ,rpad(c.module,15) Prog
  ,c.terminal terminal
  ,rpad(c.action,20) acao
  ,c.client_info
  ,c.client_identifier
  ,c.blocking_session
  ,c.final_blocking_session  
FROM all_objects a
  ,Gv$locked_object b
  ,Gv$session c
WHERE b.object_id = a.object_id
  AND b.session_id = c.sid
  AND B.INST_ID = C.INST_ID
ORDER BY 7;

select sid,serial# from v$session where serial# = 56071;
alter system kill session 'sid,serial#'
