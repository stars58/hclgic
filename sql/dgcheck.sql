SET  PAGES 100

set verify off trimspool on trimout on feedback off heading on echo off pages 100 termout off
SPOOL dgcheck.html
SET MARKUP HTML ON entmap off - 
head '<title>Database Check</title> - 
<style type="text/css"> -
    table { background: #eee; font-size: 90%; } -
    th { background: #ccc; } -
    td { padding: 0px; } -
  </style>' -
body 'text=black bgcolor=fffffff align=left' -
table 'align=center width=90% border=3 bordercolor=black bgcolor=lightgrey'

define BEGIN_WARNING = '<b><span style="color: red;">';
define END_WARNING = '</span></b>';
define BEGIN_OK = '<b><span style="color: green">OK</span></b>';


-- dataguard
alter session set nls_date_format='YYYY-MM-DD HH24:MI:SS';

Prompt <h3>Dataguard parameters</h3>

select 'Database role' "Name" , database_role "Value", decode(database_role,'PHYSICAL STANDBY','&BEGIN_OK', '&BEGIN_WARNING' || 'PHYSICAL STANDBY' ||'&END_WARNING') "Check" from v$database
union
select 'Open Mode'  "Name", open_mode "Value", decode(open_mode,'MOUNTED','&BEGIN_OK', '&BEGIN_WARNING' || 'MOUNTED' ||'&END_WARNING') "Check"from v$database
union
select 'Force Logging'  "Name", force_logging "Value", decode(force_logging,'YES','&BEGIN_OK', '&BEGIN_WARNING' || 'YES' ||'&END_WARNING') "Check"from v$database
union 
select 'DB Unqiue Name'  "Name", db_unique_name  "Value", '&BEGIN_OK' "Check"from v$database
;

Prompt <h3>Recovery Processes</h3>
select process,status,sequence#,thread# ,
(select completion_time from v$archived_log b
where a.thread#=b.thread# and a.sequence#=b.sequence#) completion_time
from v$managed_standby a
where sequence# >0;

SELECT ARCH.THREAD# "Thread", ARCH.SEQUENCE# "Last Sequence Received", APPL.SEQUENCE# "Last Sequence Applied", (ARCH.SEQUENCE# - APPL.SEQUENCE#) "Difference"
FROM
(SELECT THREAD# ,SEQUENCE# FROM V$ARCHIVED_LOG WHERE (THREAD#,FIRST_TIME ) IN (SELECT THREAD#,MAX(FIRST_TIME) FROM V$ARCHIVED_LOG GROUP BY THREAD#)) ARCH,
(SELECT THREAD# ,SEQUENCE# FROM V$LOG_HISTORY WHERE (THREAD#,FIRST_TIME ) IN (SELECT THREAD#,MAX(FIRST_TIME) FROM V$LOG_HISTORY GROUP BY THREAD#)) APPL
WHERE
ARCH.THREAD# = APPL.THREAD#
ORDER BY 1;

Prompt <h3>Archiving in last 1 hour</h3>
SELECT thread#,sequence#, first_time, next_time, applied
FROM   v$archived_log
where first_time > sysdate -1/24
ORDER BY thread#, sequence#;

Prompt <h3>Archive Gap</h3>
Prompt <i>No row is OK</i>
select * from v$archive_gap;

prompt <hr>
prompt <footer><font size="2"><i>Written by Vincent 2015</i></font></footer>
SPOOL OFF
SET MARKUP HTML OFF
SET ECHO ON

host dgcheck.html