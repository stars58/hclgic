SET  PAGES 100

set verify off trimspool on trimout on feedback off heading on echo off pages 100 termout off
SPOOL dbcheck.html
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


-- database security
Prompt <h3>Database password expiry </h3>
select PROFILE ,RESOURCE_NAME,LIMIT,decode(LIMIT,'UNLIMITED','&BEGIN_OK', '&BEGIN_WARNING' || 'UNLIMITED' ||'&END_WARNING') "Check" 
 from dba_profiles where resource_name = 'PASSWORD_LIFE_TIME'
union
select PROFILE ,RESOURCE_NAME,LIMIT,decode(LIMIT,'UNLIMITED','&BEGIN_OK', '&BEGIN_WARNING' || 'UNLIMITED' ||'&END_WARNING') "Check" 
 from dba_profiles where resource_name = 'PASSWORD_GRACE_TIME';

-- optimizer
col name format a30
col value format a20

Prompt <h3>Optimizer Mode</h3>
select name,value,decode(value,'FIRST_ROWS_10','&BEGIN_OK', '&BEGIN_WARNING' || 'FIRST_ROWS_10' ||'&END_WARNING') "Check"  from v$parameter where name ='optimizer_mode'
union 
select name,value,decode(value,'20','&BEGIN_OK', '&BEGIN_WARNING' || '20' ||'&END_WARNING') "Check" from v$parameter where name ='optimizer_index_caching'
union 
select name,value,decode(value,'20','&BEGIN_OK', '&BEGIN_WARNING' || '20' ||'&END_WARNING') "Check" from v$parameter where name ='optimizer_index_cost_adj'
union 
select name,value,decode(value,'exact','&BEGIN_OK', '&BEGIN_WARNING' || 'exact' ||'&END_WARNING') "Check" from v$parameter where name ='cursor_sharing'
;

Prompt <h3>Memory Setting</h3>
select name,value,case when value/1024/1024 >=16 then '&BEGIN_OK'  else '&BEGIN_WARNING'||'> 16M'||'&END_WARNING' end "Check" from v$parameter where name ='large_pool_size'
union 
select name,value,case when value/1024/1024 >=500 then '&BEGIN_OK'  else '&BEGIN_WARNING'||'> 500M'||'&END_WARNING' end "Check" from v$parameter where name ='shared_pool_size'
union 
select name,value,case when value/1024/1024 >=512 then '&BEGIN_OK'  else '&BEGIN_WARNING'||'> 512M'||'&END_WARNING' end "Check"from v$parameter where name ='db_cache_size'
union 
select name,value,'NA' "Check" from v$parameter where name ='sga_target'
union 
select name,value,'NA' "Check" from v$parameter where name ='memory_target'
union 
select name,value,case when value/1024/1024 >=48 then '&BEGIN_OK'  else '&BEGIN_WARNING'||'> 48M'||'&END_WARNING' end "Check" from v$parameter where name ='java_pool_size'
;





-- space management

prompt <h3>Database size by Tablespace</h3>
Prompt <i>List of tablespaces. TEMP and UNDO can be ignored. Below 5% of freespace show warning</i>
col "Size GB" format 999,999.99
col "Used (GB)" format 999,999.99
col "Free (GB)" format 999,999.99
col "Used (%)" format 999.99

select b.tablespace_name, tbs_size "Size GB", tbs_size-a.free_space "Used (GB)", a.free_space "Free (GB)", round(((tbs_size-a.free_space)/tbs_size)*100,2) "Used (%)",
case when ((tbs_size-a.free_space)/tbs_size)*100 <=95 then '&BEGIN_OK'  else '&BEGIN_WARNING'||'Not OK'||'&END_WARNING' end "Check" 
from 
(select tablespace_name, round(sum(bytes)/1024/1024/1024,2) as free_space 
from dba_free_space group by tablespace_name) a, 
(select tablespace_name, round(sum(bytes)/1024/1024/1024,2) as tbs_size from dba_data_files group by tablespace_name
UNION
select tablespace_name, round(sum(bytes)/1024/1024/1024,2) tbs_size
from dba_temp_files group by tablespace_name ) b where a.tablespace_name(+)=b.tablespace_name
order by 5 desc;

Prompt <h3>Database size by Schema</h3>
col "Size (GB)" format 999,999.99
select owner ,round(sum(bytes/1024/1024/1024),2) "Size (GB)" from dba_segments group by owner 
order by 2 desc;

Prompt <h3>ASM DiskGroup Size</h3>
Prompt <i>This is for database with ASM filesystem only. Below 10% show warning</i>
SELECT name, round(free_mb/1024,2) "FREE_GB", round(total_mb/1024,2) "TOTAL_GB", 
round(free_mb/total_mb*100,2) "% Free" , case when round(free_mb/total_mb*100,2) > 10 then '&BEGIN_OK' else '&BEGIN_WARNING'||'Not OK'||'&END_WARNING' end "Check"
FROM v$asm_diskgroup;



-- Histograms
Prompt <h3>Histograms by schema</h3>
Prompt <i>There should be no histogram for OPERA users</i>
select owner,histogram,count(*)
from dba_tab_columns
where histogram <>'NONE'
group by owner,histogram
order by owner,histogram;

-- patchset
Prompt <h3>Oracle Patches</h3>
select * from registry$history;

-- invalid objects
Prompt <h3>Invalid objects</h3>
Prompt <i>There should be no invalid objects</i>
select owner,count(*) from dba_objects where status='INVALID' group by owner order by 1;

-- Directories
Prompt <h3>Directories</h3>
select * from dba_directories;

-- 11g specific
Prompt <h2>11g Only</h2>
Prompt <i>These parameters are for 11g specific only</i>
prompt <hr>
Prompt <h3>11g specific parameters</h3>



select name,value,decode(value,'11.2.0.3','&BEGIN_OK', '&BEGIN_WARNING' || '11.2.0.3' ||'&END_WARNING') "Check"  from v$parameter where name ='compatible'
union 
select name,value,decode(value,'FALSE','&BEGIN_OK','&BEGIN_WARNING' || 'FALSE' ||'&END_WARNING') "Check"  from v$parameter where name = 'sec_case_sensitive_logon'
union 
select name,value,decode(value,'OS','&BEGIN_OK', '&BEGIN_WARNING' || 'OS' ||'&END_WARNING') "Check" from v$parameter where name = 'audit_trail'
union 
select name,value,decode(value,'FALSE','&BEGIN_OK', '&BEGIN_WARNING' || 'FALSE' ||'&END_WARNING') "Check"  from v$parameter where name = 'deferred_segment_creation'
union 
select name,value,decode(value,1,'&BEGIN_OK', '&BEGIN_WARNING' || '1' ||'&END_WARNING') "Check"  from v$parameter where name = 'plsql_optimize_level';

-- ACL views
Prompt <h3>ACLs</h3>
SELECT host, lower_port, upper_port, acl FROM   dba_network_acls;

Prompt <h3>ACL Privileges</h3>
SELECT acl,
       principal,
       privilege,
       is_grant,
       TO_CHAR(start_date, 'DD-MON-YYYY') AS start_date,
       TO_CHAR(end_date, 'DD-MON-YYYY') AS end_date
FROM   dba_network_acl_privileges;

Prompt <h3>Timezone</h3>
select property_name, property_value, decode(property_value,14,'&BEGIN_OK', '&BEGIN_WARNING' || '14' ||'&END_WARNING') "DST_PRIMARY_TT_VERSION"
from database_properties
where property_name ='DST_PRIMARY_TT_VERSION';

prompt <hr>
prompt <footer><font size="2"><i>Written by Vincent 2014</i></font></footer>
SPOOL OFF
SET MARKUP HTML OFF
SET ECHO ON

host dbcheck.html