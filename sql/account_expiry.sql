select username,account_status,profile from dba_users 
where username in ('DBSNMP','NAGIOS','OHRCDBA','SOLARWINDS); order by 2,1


alter profile &&PROFILE LIMIT PASSWORD_REUSE_TIME UNLIMITED;
alter profile &&PROFILE LIMIT PASSWORD_REUSE_MAX UNLIMITED;
/


select 'alter user '||name||' identified by values '''||password||''';' from user$ where spare4 is null and password is not null and name='&&SYS'
union
select 'alter user '||name||' identified by values '''||spare4||';'||password||''';' from user$ where spare4 is not null and password is not null and name='&&SYS';

alter profile &&PROFILE  LIMIT PASSWORD_REUSE_MAX 20;
alter profile &&PROFILE  LIMIT PASSWORD_REUSE_TIME 365;
/
