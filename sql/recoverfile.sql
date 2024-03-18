/*
This script recover datafiles that are inconsisent
*/
 declare
    l_backup number;
	
    l_sql varchar2(512);
    cursor c1 is select * from v$recover_file;
	
	l_sql2 varchar2(512);
	cursor c2 is Select file# from v$datafile where status = ’OFFLINE’;
  begin
    select count(*) into l_backup from v$backup where status=’ACTIVE’;
	if l_backup > 0 then
	   l_sql := 'alter database end backup';
	   execute immediate (l_sql);
	end if;
	
    for c1rec in c1 loop
       l_sql := 'alter database recover datafile ' || c1rec.file# ;
        dbms_output.put_line(l_sql);
       execute immediate (l_sql);
    end loop;
	
    for c2rec in c2 loop
       l_sql2 := 'alter database datafile ' || c1rec.file# || ' online';
        dbms_output.put_line(l_sql2);
       execute immediate (l_sql2);
    end loop;	
 end;