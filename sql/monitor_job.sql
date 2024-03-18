Monitoring job-scheduling
Jobs can be monitored using Oracle Enterprise Manager 10g. It's also possible to use a number of views that have been created in Oracle 10g. We will discuss some of these views here.

To show details on job run:
select log_date
,      job_name
,      status
,      req_start_date
,      actual_start_date
,      run_duration
from   dba_scheduler_job_run_details
  
To show running jobs:
select job_name
,      session_id
,      running_instance
,      elapsed_time
,      cpu_used
from dba_scheduler_running_jobs;
  
To show job history:
 select log_date
 ,      job_name
 ,      status
 from dba_scheduler_job_log;


show all schedules:
select schedule_name, schedule_type, start_date, repeat_interval 
from dba_scheduler_schedules;

show all jobs and their attributes:
select *
from dba_scheduler_jobs


show all program-objects and their attributes
select *
from dba_scheduler_programs;

show all program-arguments:
select *
from   dba_scheduler_program_args;

