Para corrigir os erros do tipo: ORA-04023 e ORA-06508
===============================================================

Link que serviu de base à resolução do problema
https://ittutorial.org/ora-04023-object-could-not-be-validated-or-authorized/


Resolução:

1- Executar o seguinte SELECT para encontrar quais os objectos em que temos a incoerência dos timestamps

select (select u.name from sys.user$ u where do.owner# = u.user#) owner, do.owner#, decode(do.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE',7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE',11, 'PACKAGE BODY', 12, 'TRIGGER') as type,
do.obj# d_obj,do.name d_name, do.type# d_type, po.obj# p_obj,po.name p_name,to_char(p_timestamp,'DD-MON-YYYY HH24:MI:SS') "P_Timestamp",to_char(po.stime ,'DD-MON-YYYY HH24:MI:SS') "STIME",
decode(sign(po.stime-p_timestamp),0,'SAME','*DIFFER*') X from sys.obj$ do, sys.dependency$ d, sys.obj$ po where P_OBJ#=po.obj#(+) and D_OBJ#=do.obj# and do.status=1 /*dependent is valid*/ and po.status=1 /*parent is valid*/
and po.stime!=p_timestamp /*parent timestamp not match*/ order by 1;


2- Posteriormente produzir os seguintes comandos para invalidar os objectos incoerentes

select  'exec DBMS_UTILITY.INVALIDATE (' || d_obj || ');'
from (select (select u.name from sys.user$ u where do.owner# = u.user#) owner, do.owner#, decode(do.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE',7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE',11, 'PACKAGE BODY', 12, 'TRIGGER') as type,
do.obj# d_obj,do.name d_name, do.type# d_type, po.obj# p_obj,po.name p_name,to_char(p_timestamp,'DD-MON-YYYY HH24:MI:SS') "P_Timestamp",to_char(po.stime ,'DD-MON-YYYY HH24:MI:SS') "STIME",
decode(sign(po.stime-p_timestamp),0,'SAME','*DIFFER*') X from sys.obj$ do, sys.dependency$ d, sys.obj$ po where P_OBJ#=po.obj#(+) and D_OBJ#=do.obj# and do.status=1 /*dependent is valid*/ and po.status=1 /*parent is valid*/
and po.stime!=p_timestamp /*parent timestamp not match*/ order by 1);

select  'exec DBMS_UTILITY.INVALIDATE (' || p_obj || ');'
from (select (select u.name from sys.user$ u where do.owner# = u.user#) owner, do.owner#, decode(do.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE',7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE',11, 'PACKAGE BODY', 12, 'TRIGGER') as type,
do.obj# d_obj,do.name d_name, do.type# d_type, po.obj# p_obj,po.name p_name,to_char(p_timestamp,'DD-MON-YYYY HH24:MI:SS') "P_Timestamp",to_char(po.stime ,'DD-MON-YYYY HH24:MI:SS') "STIME",
decode(sign(po.stime-p_timestamp),0,'SAME','*DIFFER*') X from sys.obj$ do, sys.dependency$ d, sys.obj$ po where P_OBJ#=po.obj#(+) and D_OBJ#=do.obj# and do.status=1 /*dependent is valid*/ and po.status=1 /*parent is valid*/
and po.stime!=p_timestamp /*parent timestamp not match*/ order by 1);


3- Executar na bd com o UTILIZADOR SYS!!

Alter system flush shared_pool;
Alter system flush buffer_cache;
Executar todos os comandos produzidos pelos 2 selects de cima   
       Exemplo de comandos produzidos: exec DBMS_UTILITY.INVALIDATE (24477744);
Finalmente executar o utlrp.sql (para compilar todos os objectos descompilados na bd)

