-- by day
select trunc(completion_time),round(sum(block_size*blocks)/1024/1024/1024,2) "GB", count(*) from v$archived_log 
where dest_id=1 group by trunc(completion_time) order by 1,2;

-- by hour
select trunc(completion_time,'hh'),round(sum(block_size*blocks)/1024/1024/1024,2) "GB", count(*) from v$archived_log 
where dest_id=1 group by trunc(completion_time,'hh') order by 1,2;
