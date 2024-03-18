break on report
 compute sum of Value on report
select METRIC_NAME,avg(AVERAGE) as "Value"
   from dba_hist_sysmetric_summary
   where METRIC_NAME in ('Physical Read Total IO Requests Per Sec','Physical Write Total IO Requests Per Sec')
   group by METRIC_NAME;
 
-------------------------

select to_char(begin_time,'hh24'),trunc(avg(Phys_IO_Tot_MBps_AVG)) Phys_IO_Tot_MBps_AVG, trunc(avg(Phys_IO_Tot_MBps_MAX)) Phys_IO_Tot_MBps_MAX,trunc(avg(Phys_IOPS_Tot_AVG)) Phys_IOPS_Tot_AVG,
 trunc(avg(Phys_IOPS_Tot_MAX)) Phys_IOPS_Tot_MAX,trunc(avg(Host_CPU_util_AVG)) Host_CPU_util_AVG,trunc(avg(Host_CPU_util_MAX)) Host_CPU_util_MAX from
 (
 select min(begin_time) begin_time ,
 snap_id,
 sum(case metric_name when 'Physical Read Total Bytes Per Sec' then average end)/1024/1024 +
 sum(case metric_name when 'Physical Write Total Bytes Per Sec' then average end)/1024/1024 +
 sum(case metric_name when 'Redo Generated Per Sec' then average end)/1024/1024 Phys_IO_Tot_MBps_AVG,
 sum(case metric_name when 'Physical Read Total Bytes Per Sec' then maxval end)/1024/1024 +
 sum(case metric_name when 'Physical Write Total Bytes Per Sec' then maxval end)/1024/1024 +
 sum(case metric_name when 'Redo Generated Per Sec' then maxval end)/1024/1024 Phys_IO_Tot_MBps_MAX,
 sum(case metric_name when 'Physical Read Total IO Requests Per Sec' then average end) +
 sum(case metric_name when 'Physical Write Total IO Requests Per Sec' then average end) +
 sum(case metric_name when 'Redo Writes Per Sec' then average end) Phys_IOPS_Tot_AVG,
 sum(case metric_name when 'Physical Read Total IO Requests Per Sec' then maxval end) +
 sum(case metric_name when 'Physical Write Total IO Requests Per Sec' then maxval end) +
 sum(case metric_name when 'Redo Writes Per Sec' then maxval end) Phys_IOPS_Tot_MAX,
 sum(case metric_name when 'Host CPU Utilization (%)' then average end) Host_CPU_util_AVG,
 sum(case metric_name when 'Host CPU Utilization (%)' then maxval end) Host_CPU_util_MAX
 from dba_hist_sysmetric_summary
 where begin_time> sysdate-7
 group by snap_id
 )
 group by to_char(begin_time,'hh24')
 order by 1;
 
