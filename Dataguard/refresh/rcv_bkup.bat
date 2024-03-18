set w_bkup=d:\backup
set w_pri=sys/opera10g@opera
set w_standby=sys/opera10g@standby

echo off
echo run { > dg_bkup.rcv 
echo configure channel device type disk format '%w_bkup%\%%U'; >> dg_bkup.rcv
echo backup database; >> dg_bkup.rcv
echo backup current controlfile for standby; >> dg_bkup.rcv
echo sql "alter system archive log current"; >> dg_bkup.rcv
echo backup archivelog from time 'sysdate -1/24'; >> dg_bkup.rcv
echo } >> dg_bkup.rcv
echo on

rman target %w_pri% @d:\backupdg_bkup.rcv

rem ---------------------------------------
delete all files in oradata
"startup nomount" in standby database 
rem ---------------------------------------

echo off
echo run { > dg_restore.rcv 
echo duplicate target database for standby dorecover nofilenamecheck; >> dg_restore.rcv 
echo } >> dg_restore.rcv 
echo on

rman target %w_pri% auxiliary %w_standby% @d:\backup\dg_restore.rcv