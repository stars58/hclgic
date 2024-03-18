/*
 This script retrieve location of data,log,archive file.
*/
SET MARKUP HTML ON
spool d:\vng.html
col name format a25
col value format a50
select name, value as location from v$parameter
where name in ('background_dump_dest','ifile','control_files','spfile')
or (name like 'log_archive_dest%' and value like 'location%')
or (name like 'log_archive_dest%' and value like 'service%')
union
select distinct 'data_files',substr(name,1,instr(name,'\',-1)) n from v$datafile
union
select distinct 'log_files', substr(member,1,instr(member,'\',-1))  from v$logfile
;
spool off
SET markup HTML off