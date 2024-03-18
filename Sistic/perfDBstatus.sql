SET SQLFORMAT csv;
spool 'c:\orawork\sqlsistic\perfDBstatus.log' append;
select NAME , B.* from (
select INST_ID,GROUP_ID, METRIC_NAME, ROUND(VALUE,2) value From sys.GV_$SYSMETRIC )
pivot (SUM(VALUE) for METRIC_NAME in  ( 
 'CPU Usage Per Txn',
'Current Logons Count',
 'Database CPU Time Ratio',
 'Database Wait Time Ratio',
'Database Time Per Sec',
 'Response Time Per Txn',
 'SQL Service Response Time',
 'User Transaction Per Sec',
 'Host CPU Utilization (%)',
'Average Active Sessions' 
)) B,V$DATABASE A WHERE group_id=2
order by 2;
spool off;
exit;