--
-- Purpose :generate backup script
-- gen script on standby database, 
-- run on production database
--
conn sys/opera10g as sysdba
set heading off feedback off
spool d:\backup\gen_bkup.rcv
prompt run {
select 'backup incremental from scn ' || current_scn || ' database format ''d:\backup\ora_%U'';' from v$database;
prompt backup current controlfile for standby format 'd:\backup\ctl_stby';;
prompt }
spool off
set heading on 


--
-- Purpose :generate backup script
-- gen on production database
-- run on standby database
--
set heading off feedback off serveroutput on
spool d:\backup\gen_restore.rcv
prompt run {
prompt Shutdown immediate;;
prompt startup nomount;;
select 'Set DBID=' || dbid || ';' from v$database;
prompt }
prompt restore controlfile from 'd:\backup\ctl_stby';;
prompt alter database mount;;
prompt catalog start with 'd:\backup';;

declare
  cursor c0 is select max(sequence#) sequence from v$managed_standby;
  cursor c1(p_seq in number) is Select file# from v$datafile where trunc(creation_time) >= 
    (select first_time from v$archived_log where sequence# in p_seq);
  w_restore varchar2(100);
begin
  for c0rec in c0 loop
     for c1rec in c1(c0rec.sequence)  loop
        w_restore := w_restore || c1rec.file# ||',';
     end loop;
  end loop;

  if w_restore is not null then
    dbms_output.put_line('restore datafile ' || w_restore );
  end if;
end;
/

prompt recover database noredo;;
spool off;
set heading on feedback on
