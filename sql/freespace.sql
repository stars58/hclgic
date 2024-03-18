-- new version
clear columns
column tablespace format a10
column total_gb format 999,999.99
column used_gb format 999,999.99
column free_gb format 999,999.99
column pct_used format 999.99
column graph format a25 heading "GRAPH (X=5%)"
column status format a10
compute sum of total_gb on report
compute sum of used_gb on report
compute sum of free_gb on report
break on report 

select  total.ts tablespace,
        DECODE(total.gb,null,'OFFLINE',dbat.status) status,
	total.gb total_gb,
	NVL(total.gb - free.gb,total.gb) used_gb,
	NVL(free.gb,0) free_gb,
        DECODE(total.gb,NULL,0,NVL(ROUND((total.gb - free.gb)/(total.gb)*100,2),100)) pct_used,
	CASE WHEN (total.gb IS NULL) THEN '['||RPAD(LPAD('OFFLINE',13,'-'),20,'-')||']'
	ELSE '['|| DECODE(free.gb,
                             null,'XXXXXXXXXXXXXXXXXXXX',
                             NVL(RPAD(LPAD('X',trunc((100-ROUND( (free.gb)/(total.gb) * 100, 2))/5),'X'),20,'-'),
		'--------------------'))||']' 
         END as GRAPH
from
	(select tablespace_name ts, round(sum(bytes)/1024/1024/1024,2) gb from dba_data_files group by tablespace_name) total,
	(select tablespace_name ts, round(sum(bytes)/1024/1024/1024,2) gb from dba_free_space group by tablespace_name) free,
        dba_tablespaces dbat
where total.ts=free.ts(+) and
      total.ts=dbat.tablespace_name
UNION ALL
select  sh.tablespace_name, 
        'TEMP',
	SUM(sh.bytes_used+sh.bytes_free)/1024/1024/1024 total_gb,
	SUM(sh.bytes_used)/1024/1024/1024 used_gb,
	SUM(sh.bytes_free)/1024/1024/1024 free_gb,
        ROUND(SUM(sh.bytes_used)/SUM(sh.bytes_used+sh.bytes_free)*100,2) pct_used,
        '['||DECODE(SUM(sh.bytes_free),0,'XXXXXXXXXXXXXXXXXXXX',
              NVL(RPAD(LPAD('X',(TRUNC(ROUND((SUM(sh.bytes_used)/SUM(sh.bytes_used+sh.bytes_free))*100,2)/5)),'X'),20,'-'),
                '--------------------'))||']'
FROM v$temp_space_header sh
GROUP BY tablespace_name
order by 6 desc;

-- for auto extend

set linesize 100
set pagesize 100

select
                a.tablespace_name,
                round(SUM(a.bytes)/(1024*1024*1024)) CURRENT_GB,
                round(SUM(decode(b.maxextend, null, A.BYTES/(1024*1024*1024), 
                b.maxextend*8192/(1024*1024*1024)))) MAX_GB,
                (SUM(a.bytes)/(1024*1024*1024) - round(c.Free/1024/1024/1024)) USED_GB,
                round((SUM(decode(b.maxextend, null, A.BYTES/(1024*1024*1024), 
                b.maxextend*8192/(1024*1024*1024))) - (SUM(a.bytes)/(1024*1024*1024) - 
                round(c.Free/1024/1024/1024))),2) FREE_GB,
                round(100*(SUM(a.bytes)/(1024*1024*1024) - 
                round(c.Free/1024/1024/1024))/(SUM(decode(b.maxextend, null, A.BYTES/(1024*1024*1024), 
                b.maxextend*8192/(1024*1024*1024))))) USED_PCT
from
                dba_data_files a,
                sys.filext$ b,
                (SELECT
                               d.tablespace_name ,sum(nvl(c.bytes,0)) Free
                FROM
                               dba_tablespaces d,
                               DBA_FREE_SPACE c
                WHERE
                               d.tablespace_name = c.tablespace_name(+)
                               group by d.tablespace_name) c
WHERE
                a.file_id = b.file#(+)
                and a.tablespace_name = c.tablespace_name
GROUP BY a.tablespace_name, c.Free/1024
ORDER BY tablespace_name;

-- for normal
select nvl(b.tablespace_name,
 nvl(a.tablespace_name,'UNKNOWN')) "Tablespace",
 kbytes_alloc "Allocated MB",
 kbytes_alloc-nvl(kbytes_free,0) "Used MB",
 nvl(kbytes_free,0) "Free MB",
 ((kbytes_alloc-nvl(kbytes_free,0))/kbytes_alloc) "Used",
 data_files "Data Files"
from ( select sum(bytes)/1024/1024/1024 Kbytes_free,
 max(bytes)/1024/1024/1024 largest,
 tablespace_name
from sys.dba_free_space
 group by tablespace_name ) a,
 ( select sum(bytes)/1024/1024/1024 Kbytes_alloc,
 tablespace_name,
 count(*) data_files
from sys.dba_data_files
 group by tablespace_name )b
 where a.tablespace_name (+) = b.tablespace_name
 order by 1


-- for ASM
set lines 255
col path for a35
col Diskgroup for a15
col DiskName for a20
col disk# for 999
col total_mb for 999,999,999
col free_mb for 999,999,999
compute sum of total_mb on DiskGroup
compute sum of free_mb on DiskGroup
break on DiskGroup skip 1 on report -

set pages 255

select a.name DiskGroup, b.disk_number Disk#, b.name DiskName, b.total_mb, b.free_mb, b.path, b.header_status
from v$asm_disk b, v$asm_diskgroup a
where a.group_number (+) =b.group_number
order by b.group_number, b.disk_number, b.name
/