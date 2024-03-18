SET SQLFORMAT csv;
spool 'c:\orawork\sqlsistic\dailyDBasm.log';
SELECT name, round((total_mb-free_mb)/1024,2) "USED_GB ",round(free_mb/1024,2) "FREE_GB", round(total_mb/1024,2) Total_GB, round(free_mb/total_mb*100,2) "% Free" 
 FROM v$asm_diskgroup ;
spool off;
exit;