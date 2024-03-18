--SET SQLFORMAT csv;
spool 'c:\orawork\sqlsistic\chkusername.log' append;
select name, username,account_status from dba_users, v$database where lower(username) like '%dinhngoctuanvu%';
spool off;
exit;