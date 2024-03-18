col sga format 999,990.00;
col pga format 999,990.00;
col total_mem_gb format 999,990.00;

select a.inst_id, db_time_pct,cpu_time_pct,sga,pga,total_mem_gb from 
(WITH sys_time AS (
        SELECT inst_id, SUM(CASE stat_name WHEN 'DB time'
                            THEN VALUE END) db_time,
            SUM(CASE WHEN stat_name IN ('DB CPU', 'background cpu time')
                THEN  VALUE  END) cpu_time
          FROM gv$sys_time_model
         GROUP BY inst_id                 )
    SELECT inst_id,
           ROUND(db_time/1000000,2) db_time_secs,
          ROUND(db_time*100/SUM(db_time) over(),2) db_time_pct,
          ROUND(cpu_time/1000000,2) cpu_time_secs,
          ROUND(cpu_time*100/SUM(cpu_time) over(),2)  cpu_time_pct
     FROM     sys_time
     JOIN gv$instance USING (inst_id)
) a,
(
SELECT A.INST_ID, SGA,PGA,SGA+PGA TOTAL_MEM_GB FROM 
(select inst_id,sum(value)/1024/1024/1024 sga from gv$sga group by inst_id) A,
(select A.inst_id ,sum(value)/1024/1024/1024 PGA 
from gv$sesstat a, gv$statname b 
where a.inst_id=b.inst_id and
b.name = 'session pga memory' and 
a.statistic# = b.statistic#
group by A.inst_ID) B
WHERE A.INST_ID=B.INST_ID) b
where a.inst_id=b.inst_id;