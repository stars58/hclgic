SET PAGESIZE 0;
SET SQLFORMAT csv;
SET FEEDBACK OFF;
spool 'c:\orawork\sqlsistic\dailyDBstatus.log' append;
SELECT 
Name , STATUS,
(SELECT MAX(current_utilization) FROM ((select INST_ID,current_utilization from gv$resource_limit where resource_name in ('sessions')))) Sessions,
(SELECT MAX(current_utilization) FROM ((select INST_ID,current_utilization from gv$resource_limit where resource_name in ('processes')))) Processes,
(SELECT COUNT(*) FROM gv$session where status='ACTIVE') "Active Session",
(SELECT COUNT(*) FROM gv$session where status='INACTIVE') "Inactive Session",
(SELECT decode(count(*),0,'No','Yes') FROM GV$LOCK A, GV$LOCK B WHERE  a.id1=b.id1 and a.id2=b.id2 and a.type = b.type and b.request>0) "DB Locks",
(select decode(count(*),0,'No','Yes') from dba_waiters) "Blocking Session",
(select  listagg(tablespace_name,':') within group (order by tablespace_name)from dba_tablespace_usage_metrics WHERE USED_PERCENT > 80) "Tablesapce Above 80",
(SELECT  CEIL ((( space_used - space_reclaimable ) / space_limit) * 100) FROM v$recovery_file_dest) "FRA Usage",
(select GAP_STATUS from V$ARCHIVE_DEST_STATUS where DESTINATION is not null) "DR Sync",
(select round(sum(bytes / (1024*1024*1024)),2) "GB" from dba_data_files) DB_SIZE
FROM v$instance, v$database;
spool off;
exit;


