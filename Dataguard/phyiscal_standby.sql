
-- NAME: DG_phy_stby_diag.sql     
-- ------------------------------------------------------------------------  
-- AUTHOR:   
--    Michael Smith - Oracle Support Services - DataServer Group 
--    Copyright 2002, Oracle Corporation       
-- ------------------------------------------------------------------------  
-- PURPOSE:  
--    This script is to be used to assist in collection information to help
--    troubeshoot Data Guard issues.
-- ------------------------------------------------------------------------  
-- DISCLAIMER:  
--    This script is provided for educational purposes only. It is NOT   
--    supported by Oracle World Wide Technical Support.  
--    The script has been tested and appears to work as intended.  
--    You should always run new scripts on a test instance initially.  
-- ------------------------------------------------------------------------  
-- Script output is as follows: 
 
set echo off 
set feedback off 
column timecol new_value timestamp 
column spool_extension new_value suffix 
select to_char(sysdate,'Mondd_hhmi') timecol, 
'.out' spool_extension from sys.dual; 
column output new_value dbname 
select value || '_' output 
from v$parameter where name = 'db_name'; 
spool dgdiag_phystby_&&dbname&�tamp&&suffix 
set lines 200 
set pagesize 35 
set trim on 
set trims on 
alter session set nls_date_format = 'MON-DD-YYYY HH24:MI:SS'; 
set feedback on 
select to_char(sysdate) time from dual; 
 
set echo on 
 
-- 
-- ARCHIVER can be  (STOPPED | STARTED | FAILED) FAILED means that the archiver failed 
-- to archive a -- log last time, but will try again within 5 minutes. LOG_SWITCH_WAIT 
-- The ARCHIVE LOG/CLEAR LOG/CHECKPOINT event log switching is waiting for. Note that  
-- if ALTER SYSTEM SWITCH LOGFILE is hung, but there is room in the current online  
-- redo log, then value is NULL  
 
column host_name format a20 tru 
column version format a9 tru 
select instance_name,host_name,version,archiver,log_switch_wait from v$instance; 
 
-- The following select will give us the generic information about how this standby is 
-- setup.  The database_role should be standby as that is what this script is intended  
-- to be ran on.  If protection_level is different than protection_mode then for some 
-- reason the mode listed in protection_mode experienced a need to downgrade.  Once the 
-- error condition has been corrected the protection_level should match the protection_mode 
-- after the next log switch. 
 
column ROLE format a7 tru 
select name,database_role,log_mode,controlfile_type,protection_mode,protection_level  
from v$database; 
 
-- Force logging is not mandatory but is recommended.  Supplemental logging should be enabled 
-- on the standby if a logical standby is in the configuration. During normal  
-- operations it is acceptable for SWITCHOVER_STATUS to be SESSIONS ACTIVE or NOT ALLOWED. 
 
column force_logging format a13 tru 
column remote_archive format a14 tru 
column dataguard_broker format a16 tru 
select force_logging,remote_archive,supplemental_log_data_pk,supplemental_log_data_ui, 
switchover_status,dataguard_broker from v$database;  
 
-- This query produces a list of all archive destinations and shows if they are enabled, 
-- what process is servicing that destination, if the destination is local or remote, 
-- and if remote what the current mount ID is. For a physical standby we should have at 
-- least one remote destination that points the primary set but it should be deferred.
 
COLUMN destination FORMAT A35 WRAP 
column process format a7 
column archiver format a8 
column ID format 99 
 
select dest_id "ID",destination,status,target, 
archiver,schedule,process,mountid  
from v$archive_dest; 
 
-- If the protection mode of the standby is set to anything higher than max performance
-- then we need to make sure the remote destination that points to the primary is set
-- with the correct options else we will have issues during switchover.
 
select dest_id,process,transmit_mode,async_blocks, 
net_timeout,delay_mins,reopen_secs,register,binding 
from v$archive_dest; 
 
-- The following select will show any errors that occured the last time an attempt to 
-- archive to the destination was attempted.  If ERROR is blank and status is VALID then 
-- the archive completed correctly. 
 
column error format a55 tru 
select dest_id,status,error from v$archive_dest; 
 
-- Determine if any error conditions have been reached by querying thev$dataguard_status 
-- view (view only available in 9.2.0 and above): 
 
column message format a80 
select message, timestamp 
from v$dataguard_status 
where severity in ('Error','Fatal') 
order by timestamp; 
 
-- The following query is ran to get the status of the SRL's on the standby.  If the
-- primary is archiving with the LGWR process and SRL's are present (in the correct
-- number and size) then we should see a group# active.
 
select group#,sequence#,bytes,used,archived,status from v$standby_log;

-- The above SRL's should match in number and in size with the ORL's returned below: 
 
select group#,thread#,sequence#,bytes,archived,status from v$log; 

-- Query v$managed_standby to see the status of processes involved in the 
-- configuration.
 
select process,status,client_process,sequence#,block#,active_agents,known_agents
from v$managed_standby;

-- Verify that the last sequence# received and the last sequence# applied to standby 
-- database.

select al.thrd "Thread", almax "Last Seq Received", lhmax "Last Seq Applied"
from (select thread# thrd, max(sequence#) almax
      from v$archived_log
      where resetlogs_change#=(select resetlogs_change# from v$database)
      group by thread#) al,
     (select thread# thrd, max(sequence#) lhmax
      from v$log_history
      where resetlogs_change#=(select resetlogs_change# from v$database)
      group by thread#) lh
where al.thrd = lh.thrd;

-- The V$ARCHIVE_GAP fixed view on a physical standby database only returns the next 
-- gap that is currently blocking redo apply from continuing. After resolving the
-- identified gap and starting redo apply, query the V$ARCHIVE_GAP fixed view again 
-- on the physical standby database to determine the next gap sequence, if there is
-- one. 

select * from v$archive_gap; 

-- Non-default init parameters. 

set numwidth 5 
column name format a30 tru 
column value format a50 wra 
select name, value 
from v$parameter 
where isdefault = 'FALSE';
 
spool off


 - - - - - - - - - - - - - - - -  Script ends here  - - - - - - - - - - - - - - - -

- - - - - - - - - - - - - - - - Script begins here - - - - - - - - - - - - - - - -

-- NAME: dg_prim_diag.sql  (Run on PRIMARY with a LOGICAL or PHYSICAL STANDBY)
-- ------------------------------------------------------------------------  
--    Copyright 2002, Oracle Corporation       
-- LAST UPDATED: 2/23/04
--
-- Usage: @dg_prim_diag
-- ------------------------------------------------------------------------  
-- PURPOSE:  
--    This script is to be used to assist in collection information to help
--    troubeshoot Data Guard issues with an emphasis on Logical Standby.
-- ------------------------------------------------------------------------  
-- DISCLAIMER:  
--    This script is provided for educational purposes only. It is NOT   
--    supported by Oracle World Wide Technical Support.  
--    The script has been tested and appears to work as intended.  
--    You should always run new scripts on a test instance initially.  
-- ------------------------------------------------------------------------  
-- Script output is as follows: 
 
set echo off 
set feedback off 
column timecol new_value timestamp 
column spool_extension new_value suffix 
select to_char(sysdate,'Mondd_hhmi') timecol, 
'.out' spool_extension from sys.dual; 
column output new_value dbname 
select value || '_' output 
from v$parameter where name = 'db_name'; 
spool dg_prim_diag_&&dbname&�tamp&&suffix 
set linesize 79
set pagesize 35 
set trim on 
set trims on 
alter session set nls_date_format = 'MON-DD-YYYY HH24:MI:SS'; 
set feedback on 
select to_char(sysdate) time from dual; 
 
set echo on 
 
-- In the following the database_role should be primary as that is what
-- this script is intended to be run on.  If protection_level is different
-- than protection_mode then for some reason the mode listed in
-- protection_mode experienced a need to downgrade.  Once the error
-- condition has been corrected the protection_level should match the
-- protection_mode after the next log switch.

column role format a7 tru 
column name format a10 wrap

select name,database_role role,log_mode,
       protection_mode,protection_level  
from v$database; 

-- ARCHIVER can be (STOPPED | STARTED | FAILED). FAILED means that the
-- archiver failed to archive a log last time, but will try again within 5
-- minutes. LOG_SWITCH_WAIT The ARCHIVE LOG/CLEAR LOG/CHECKPOINT event log
-- switching is waiting for.  Note that if ALTER SYSTEM SWITCH LOGFILE is
-- hung, but there is room in the current online redo log, then value is
-- NULL

column host_name format a20 tru 
column version format a9 tru 

select instance_name,host_name,version,archiver,log_switch_wait 
from v$instance; 
  
-- The following query give us information about catpatch.
-- This way we can tell if the procedure doesn't match the image.

select version, modified, status from dba_registry 
where comp_id = 'CATPROC';

-- Force logging is not mandatory but is recommended.  Supplemental
-- logging must be enabled if the standby associated with this primary is
-- a logical standby. During normal operations it is acceptable for
-- SWITCHOVER_STATUS to be SESSIONS ACTIVE or TO STANDBY.

column force_logging format a13 tru 
column remote_archive format a14 tru 
column dataguard_broker format a16 tru 

select force_logging,remote_archive,
       supplemental_log_data_pk,supplemental_log_data_ui, 
       switchover_status,dataguard_broker 
from v$database;  
 
-- This query produces a list of all archive destinations.  It shows if
-- they are enabled, what process is servicing that destination, if the
-- destination is local or remote, and if remote what the current mount ID
-- is.

column destination format a35 wrap 
column process format a7 
column archiver format a8 
column ID format 99 
column mid format 99
 
select dest_id "ID",destination,status,target,
       schedule,process,mountid  mid
from v$archive_dest order by dest_id;
 
-- This select will give further detail on the destinations as to what
-- options have been set.  Register indicates whether or not the archived
-- redo log is registered in the remote destination control file.

set numwidth 8
column ID format 99 

select dest_id "ID",archiver,transmit_mode,affirm,async_blocks async,
       net_timeout net_time,delay_mins delay,reopen_secs reopen,
       register,binding 
from v$archive_dest order by dest_id;
 
-- The following select will show any errors that occured the last time
-- an attempt to archive to the destination was attempted.  If ERROR is
-- blank and status is VALID then the archive completed correctly.

column error format a55 wrap

select dest_id,status,error from v$archive_dest; 
 
-- The query below will determine if any error conditions have been
-- reached by querying the v$dataguard_status view (view only available in
-- 9.2.0 and above):

column message format a80 

select message, timestamp 
from v$dataguard_status 
where severity in ('Error','Fatal') 
order by timestamp; 
 
-- The following query will determine the current sequence number
-- and the last sequence archived.  If you are remotely archiving
-- using the LGWR process then the archived sequence should be one
-- higher than the current sequence.  If remotely archiving using the
-- ARCH process then the archived sequence should be equal to the
-- current sequence.  The applied sequence information is updated at
-- log switch time.

select ads.dest_id,max(sequence#) "Current Sequence",
       max(log_sequence) "Last Archived"
from v$archived_log al, v$archive_dest ad, v$archive_dest_status ads 
where ad.dest_id=al.dest_id 
and al.dest_id=ads.dest_id 
group by ads.dest_id; 
 
-- The following select will attempt to gather as much information as
-- possible from the standby.  SRLs are not supported with Logical Standby
-- until Version 10.1.

set numwidth 8
column ID format 99 
column "SRLs" format 99 
column Active format 99 

select dest_id id,database_mode db_mode,recovery_mode, 
       protection_mode,standby_logfile_count "SRLs",
       standby_logfile_active ACTIVE, 
       archived_seq# 
from v$archive_dest_status; 

-- Query v$managed_standby to see the status of processes involved in
-- the shipping redo on this system.  Does not include processes needed to
-- apply redo.

select process,status,client_process,sequence#
from v$managed_standby;
 
-- The following query is run on the primary to see if SRL's have been
-- created in preparation for switchover.

select group#,sequence#,bytes from v$standby_log; 
 
-- The above SRL's should match in number and in size with the ORL's
-- returned below:

select group#,thread#,sequence#,bytes,archived,status from v$log; 
 
-- Non-default init parameters. 

set numwidth 5 
column name format a30 tru 
column value format a48 wra 
select name, value 
from v$parameter 
where isdefault = 'FALSE';
 
spool off

 - - - - - - - - - - - - - - - -  Script ends here  - - - - - - - - - - - - - - - -
select 'Last applied  : ' Logs, to_char(next_time,'DD-MON-YY:HH24:MI:SS') Time 
     from v$archived_log
     where sequence# = (select max(sequence#) from v$archived_log where applied='YES') 
     union 
     select 'Last received : ' Logs, to_char(next_time,'DD-MON-YY:HH24:MI:SS') Time 
     from v$archived_log 
    where sequence# = (select max(sequence#) from v$archived_log); 


