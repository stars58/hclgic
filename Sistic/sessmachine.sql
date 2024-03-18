Select * From (select inst_id, machine From gv$session)
pivot (count(*) for inst_id in (1,2));