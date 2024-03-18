@echo off
set oracle_home_grid=d:\oracle\11203\grid
rem  Author:  Vincent
rem  Date : 2016
set oracle_home_db=d:\oracle\11203\db
set oracle_diag=d:\orabase\diag
:start
cls
echo ==========  Main Menu =========== 
echo   1: CRS status all
echo   2: CRS check cluster
echo   3: Nodeapps status
echo   4: Database status
echo   5: Service status
echo   6: Listener status
echo   7: Scan listener status
echo   8: Show alert log
echo   9: Database Uptime
echo   x: Exit
echo ================================= 
echo.
set /p userinp=choose a number(1-8):
set userinp=%userinp:~0,1%
if "%userinp%"=="1" goto 1
if "%userinp%"=="2" goto 2
if "%userinp%"=="3" goto 3
if "%userinp%"=="4" goto 4
if "%userinp%"=="5" goto 5
if "%userinp%"=="6" goto 6
if "%userinp%"=="7" goto 7
if "%userinp%"=="8" goto 8
if "%userinp%"=="9" goto 9
if "%userinp%"=="x" goto x

echo Invalid choice. Please select number 1-9
pause
goto start
:1
%oracle_home_grid%\bin\crsctl stat res -t
goto end
:2
%oracle_home_grid%\bin\crsctl check cluster
goto end
:3
call %oracle_home_grid%\bin\srvctl status nodeapps
goto end
:4
call %oracle_home_grid%\bin\srvctl status database -d slimsgdg
goto end
:5
call %oracle_home_grid%\bin\srvctl status service -d slimsgdg
goto end
:6
call %oracle_home_grid%\bin\srvctl status listener
goto end
:7
call %oracle_home_grid%\bin\srvctl status scan_listener
goto end
:8
call adrci exec="show alert"
goto end
:9
call sqlplus opera/opera@opera @d:\orainstall\vng\\uptime.sql
goto end

:x
pause
goto exit

:end 
pause
goto start

:exit


