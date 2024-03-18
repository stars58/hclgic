col owner format a06 ;
col job_name format a20;
col elapsed_time format a16

select owner,job_name,session_id,running_instance,elapsed_time
from dba_scheduler_running_jobs

/
