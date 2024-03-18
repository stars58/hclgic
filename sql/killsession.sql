/*
THIS PROCEDURE KILLS A BLOCKING LOCK.
AUTHOR : VINCENT NG
*/
DECLARE
  CURSOR C1 IS
	SELECT SID,SERIAL#, TERMINAL, CLIENT_INFO FROM V$SESSION WHERE SID IN 
           (SELECT BLOCKING_SESSION FROM V$SESSION WHERE BLOCKING_SESSION_STATUS='VALID' and seconds_in_wait >= 60);

BEGIN
  FOR C1REC IN C1 LOOP
     EXECUTE IMMEDIATE 'alter system KILL session ''' || C1REC.SID || ',' || C1REC.SERIAL# || '''';
  END LOOP;
END;
/
exit;


/*
THIS PROCEDURE KILLS A SESSION BASED ON USERNAME.
AUTHOR : VINCENT NG
*/
begin     
    for x in (  
            select Sid, Serial#, machine, program  
            from v$session  
            where  
                username = 'SCOTT'  
        ) loop  
        execute immediate 'Alter System Kill Session '''|| x.Sid  
                     || ',' || x.Serial# || ''' IMMEDIATE';  
    end loop;  
end;
/