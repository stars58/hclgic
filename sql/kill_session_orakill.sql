set pages 0
set feedback off
set echo off
spool c:\temp\clear_procs.bat
select 'orakill opera '||b.spid from v$session a , v$process b where
a.paddr=b.addr and a.username in ('PUBLIC')
and 
exists
(select 1 from v$bgprocess c where a.paddr <> c.paddr)
/
spool off
host c:\temp\clear_procs.bat
exit