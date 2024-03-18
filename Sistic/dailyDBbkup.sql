SET SQLFORMAT csv;
spool 'c:\orawork\sqlsistic\dailyDBrman.log' append;
 select (select instance_name from v$instance) Name,
 STATUS,
 round(ELAPSED_SECONDS/3600,2) hrs,
 ROUND(INPUT_BYTES/1024/1024/1024,2) SUM_IN_GB,
 ROUND(OUTPUT_BYTES/1024/1024/1024,2) SUM_OUT_GB
 FROM V$RMAN_BACKUP_JOB_DETAILS where trunc(start_time)=trunc(sysdate)
 order by SESSION_KEY;
spool off;
exit;