Select segment_name,segment_type,bytes/1024/1024 MB
  from dba_segments
where segment_type='TABLE' 
and segment_name= 'TB_NAME';
