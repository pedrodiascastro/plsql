select 'alter ' || object_type || ' ' || object_name ||' compile;' from user_objects 
where status = 'INVALID' and object_type != 'PACKAGE BODY';

select 'alter PACKAGE ' || object_name ||' compile PACKAGE;' from user_objects 
where status = 'INVALID' and object_type = 'PACKAGE BODY';
