spool %userprofile%\exp_sysash.csv;
set sqlformat csv;
select snap_id,  instance_number, user_id,session_id,  TO_CHAR(SAMPLE_TIME,'DD-MON-YY') SAMPLE_DATE, TO_CHAR(SAMPLE_TIME,'HH24:MI') SAMPLE_TIME,  session_state, event, sum(wait_time), sum(time_waited),count(*)
from dba_hist_active_sess_history a
where a.sample_time > SYSDATE - 3
group by snap_id, instance_number, user_id,  session_id, TO_CHAR(SAMPLE_TIME,'DD-MON-YY'), TO_CHAR(SAMPLE_TIME,'HH24:MI'),event,session_state;
spool off;