/*
THIS PROCEDURE KILLS A BLOCKING LOCK (ver 1.1).
AUTHOR : VINCENT NG
Usage : killsession l,lb,la,kb,ka
*/

--spool /tmp/killsession.log
spool c:\temp\killsession.log
set serveroutput on
DECLARE
  W_WAITIME_1 NUMBER := 120 ;
  w_curr_util number;
  w_max_util number;
  w_limit    number;
  w_instance varchar2(20);
  cnt1 number;
  cnt2 number;
  cnt3 number;
  a varchar2(10);
  
  CURSOR C1 IS
        SELECT INST_ID, SID,SERIAL#, TERMINAL, CLIENT_INFO FROM GV$SESSION WHERE SID IN
           (SELECT BLOCKING_SESSION FROM GV$SESSION WHERE BLOCKING_SESSION_STATUS='VALID' and seconds_in_wait >= W_WAITIME_1);

  CURSOR C2 IS
       select inst_id,serial#,sid From gv$session
          where last_call_et > W_WAITIME_1  and status='ACTIVE' and type='USER';

  CURSOR C3 IS		  
	   select inst_id,serial#,sid From gv$session where  program = 'JDBC Thin Client';

BEGIN
  a := '&1';

     CASE A
        when 'l' then dbms_output.put_line('** List all **');
           cnt1 := 0;
           FOR C1REC IN C1 LOOP
                cnt1 := cnt1 + 1;
           END LOOP;
           cnt2 := 0;
           FOR C2REC IN C2 LOOP
                cnt2 := cnt2 + 1;
           END LOOP;
		   cnt3 := 0;
           FOR C3REC IN C3 LOOP
                cnt3 := cnt3 + 1;
           END LOOP;		   
		   
		   DBMS_OUTPUT.PUT_LINE('================================================');	
                   select instance_name into w_instance from v$instance;
		   dbms_output.put_line('           Instance : '||w_instance);
		   select CURRENT_UTILIZATION,MAX_UTILIZATION,LIMIT_VALUE into w_curr_util , w_max_util,w_limit from v$resource_limit where resource_name = 'sessions';
		   dbms_output.put_line('Session : Current =' || w_curr_util || ', Max = ' || w_max_util  ||', Limit = ' || w_limit);
		   select CURRENT_UTILIZATION,MAX_UTILIZATION,LIMIT_VALUE into w_curr_util , w_max_util,w_limit from v$resource_limit where resource_name = 'processes';		   
		   dbms_output.put_line('Process : Current =' || w_curr_util || ', Max = ' || w_max_util  ||', Limit = ' || w_limit);	
           DBMS_OUTPUT.PUT_LINE('  ');		   
           DBMS_OUTPUT.PUT_LINE('Current : blocked = ' || cnt1 || ' active = ' || cnt2 || ' JDBC = ' || cnt3);
           DBMS_OUTPUT.PUT_LINE('=================================================');		   
        when 'lb' then dbms_output.put_line('** List blocking **');
           cnt1 := 0;
           FOR C1REC IN C1 LOOP
                cnt1 := cnt1 + 1;
                DBMS_OUTPUT.PUT_LINE('alter system KILL session ''' || C1REC.SID || ',' || C1REC.SERIAL# || ',@' || C1REC.INST_ID|| '''');
           END LOOP;
           DBMS_OUTPUT.PUT_LINE('Total : blocked ' || cnt1);
        when 'la' then dbms_output.put_line('** List active sessions **');
           cnt2 := 0;
           FOR C2REC IN C2 LOOP
                cnt2 := cnt2 + 1;
                DBMS_OUTPUT.PUT_LINE('alter system KILL session ''' || C2REC.SID || ',' || C2REC.SERIAL# ||',@' || C2REC.INST_ID||'''');
           END LOOP;
           DBMS_OUTPUT.PUT_LINE('Total : active ' || cnt2);
        when 'kb' then dbms_output.put_line('** Kill blocking session **');
           FOR C1REC IN C1 LOOP
                EXECUTE IMMEDIATE 'alter system KILL session ''' || C1REC.SID || ',' || C1REC.SERIAL# || ',@' || C1REC.INST_ID ||'''';
                DBMS_OUTPUT.PUT_LINE('alter system KILL session ''' || C1REC.SID || ',' || C1REC.SERIAL# || ',@' || C1REC.INST_ID||'''');
           END LOOP;
        when 'ka' then dbms_output.put_line('** Kill active connections **');
           FOR C2REC IN C2 LOOP
                EXECUTE IMMEDIATE 'alter system KILL session ''' || C2REC.SID || ',' || C2REC.SERIAL# || ',@' || C2REC.INST_ID ||'''';
                DBMS_OUTPUT.PUT_LINE('alter system KILL session ''' || C2REC.SID || ',' || C2REC.SERIAL# || ',@' || C2REC.INST_ID||'''');
                END LOOP;
        when 'kj' then dbms_output.put_line('** Kill JDBC connections **');
           FOR C3REC IN C3 LOOP
                EXECUTE IMMEDIATE 'alter system KILL session ''' || C3REC.SID || ',' || C3REC.SERIAL# || ',@' || C3REC.INST_ID ||'''';
                DBMS_OUTPUT.PUT_LINE('alter system KILL session ''' || C3REC.SID || ',' || C3REC.SERIAL# || ',@' || C3REC.INST_ID||'''');
                END LOOP;				
        else
           dbms_output.put_line('No Selection. Exit');
     END CASE;
END;
/
--exit;
