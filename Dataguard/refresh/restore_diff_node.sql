set heading off feedback off
SET LINESIZE 180
prompt restore controlfile from 'd:\backup\ctl_stby';;
prompt alter database mount;;
prompt catalog start with 'd:\backup';;
prompt run {
select 'set newname for datafile ' || file# || ' to ''' || replace(name,
'C:\', 'D:\') || ''';' from v$datafile;
prompt restore database;;
prompt switch datafile all;;
prompt recover database;;
prompt }
select 'sql "alter database rename file ''''' || member || ''''' to ''''' ||
replace(member, 'C:\', 'D:\') || '''''";' from v$logfile where type = 'ONLINE' order by group#;



select 'ALTER DATABASE ADD STANDBY LOGFILE GROUP ' || GROUP# || ' ''' || MEMBER  || '''' from v$logfile where member like '%A.RDO' order by group#

