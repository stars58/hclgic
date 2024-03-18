col sga format 999,990.00;
col pga format 999,990.00;
col total_mem_gb format 999,99.00;

SELECT A.INST_ID, SGA,PGA,SGA+PGA TOTAL_MEM_GB FROM 
(select inst_id,sum(value)/1024/1024/1024 sga from gv$sga group by inst_id) A,
(select A.inst_id ,sum(value)/1024/1024/1024 PGA 
from gv$sesstat a, gv$statname b 
where a.inst_id=b.inst_id and
b.name = 'session pga memory' and 
a.statistic# = b.statistic#
group by A.inst_ID) B
WHERE A.INST_ID=B.INST_ID;