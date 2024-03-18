
Prompt
Prompt *** Below are sessions waiting on locks ***
Prompt
column sess format a15
column i format 9
column l format 9
column ctime format 999999
column req format 999
column client_info format a55

set linesize 135

spool llw2.lst

SELECT a.inst_id i,DECODE(request,0,'Holder: ','Waiter: ')|| a.sid sess, a.lmode l, 
a.request Req, a.type,a.ctime,b.client_info,b.module,b.program,b.username,b.machine, b.row_wait_obj#,b.sql_id
   FROM gV$LOCK a, gv$session b
 WHERE (a.id1, a.id2, a.type) IN 
   (SELECT id1, id2, type FROM gV$LOCK WHERE request>0)
  and a.sid=b.sid and a.inst_id=b.inst_id
   ORDER BY a.id1, a.request;

spool off
