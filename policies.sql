DECLARE

   CURSOR c1 IS

        SELECT *
          FROM all_policies
         where object_owner = 'SCHEMA'
            and object_name like 'TB_NAME'
      ORDER BY object_name;

BEGIN

   FOR c1_reg IN c1 LOOP

      BEGIN

         DBMS_RLS.drop_policy (object_schema => 'SCHEMA', 
                               object_name => c1_reg.object_name, 
                               policy_name =>c1_reg.policy_name);

      end;
      
      BEGIN
      DBMS_RLS.ADD_POLICY (OBJECT_SCHEMA     => 'SCHEMA',
                          OBJECT_NAME       => 'TB_NAME',
                          POLICY_NAME       => 'predicate_0',
                          FUNCTION_SCHEMA   => 'SCHEMA',
                          POLICY_FUNCTION   => 'PREDICATE_0',
                          LONG_PREDICATE    => FALSE,
                          POLICY_TYPE       => DBMS_RLS.shared_context_sensitive);
        END;

   end loop;

END;
/
