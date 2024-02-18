create table xxx_tb_name as
SELECT * FROM tb_name
AS OF TIMESTAMP TO_TIMESTAMP('2023-01-31 16:00:00', 'YYYY-MM-DD HH24:MI:SS');
