declare
  n_security_group apex_workspaces.WORKSPACE_ID%type;
begin
  SELECT workspace_id
    INTO n_security_group
    FROM apex_workspaces
   WHERE workspace = 'WORKSPACE_NAME'; 
  wwv_flow_api.set_security_group_id(n_security_group);   APEX_UTIL.UNLOCK_ACCOUNT (p_user_name => 'ADMIN');
  commit;
end;
