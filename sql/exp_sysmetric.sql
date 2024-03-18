spool %userprofile%\exp_sysmetric.csv;
SELECT  /*csv*/    * FROM 
     (SELECT 
         SNAP_ID, INSTANCE_NUMBER, TO_CHAR(END_TIME,'DD-MON-YY') SYS_DATE, TO_CHAR(ROUND(END_TIME,'HH'),'HH24:MI') SYS_TIME, METRIC_NAME, MAXVAL
     FROM 
         DBA_HIST_SYSMETRIC_SUMMARY
         where begin_time> sysdate-7)
 pivot
    ( MAX(ROUND(MAXVAL)) 
    FOR METRIC_NAME IN ('Current Logons Count' ,'Process Limit %','Session Limit %', 'Response Time Per Txn','Average Active Sessions' ,
 'Database CPU Time Ratio', 'Database Wait Time Ratio',
 'Executions Per Sec', 'Executions Per Txn',
 'SQL Service Response Time',
'Physical Reads Per Sec','Physical Writes Per Sec',
		'Redo Generated Per Sec', 'Host CPU Utilization (%)'))
ORDER BY SNAP_ID;
spool off;