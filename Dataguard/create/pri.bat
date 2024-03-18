set oracle_sid=orcl
set oracle_base=c:\oracle
set oracle_base=c:\oracle\1020
set remote_ip=172.29.210.100
set temp_work=c:\temp

echo off
echo shutting down %hostname% ...
echo shutdown immediate; > temp.sql
echo exit; >> temp.sql
sqlplus "/ as sysdba" @%temp_work%\temp.sql

rem 
rem copy %oracle_home%\database\PWDorcl.ora %remote_ip%\c$\%oracle_home%\database\
rem copy %oracle_base%\oradata\orcl\ %remote_ip%\c$\%oracle_base%\oradata\orcl\

echo starting up %hostname% ...
echo startup; > temp.sql
echo alter database create standby controlfile as '%temp_work%\control01.ctl'; >> temp.sql
echo exit; >> temp.sql
sqlplus "/ as sysdba" @%temp_work%\temp.sql

echo on