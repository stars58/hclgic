set JAVA_HOME=C:\Tools\sqldeveloper\jdk\jre\
set PATH=%JAVA_HOME%bin;%PATH%;

set USRID=user/passwrd
set CONN=(galaxy,master,pac,venetian)
)

del dailyDBstatus.log
for %%c in %CONN% do (
  echo Connecting to %%c
  C:\Tools\sqlcl\bin\sql %USRID%@%%c @c:\orawork\sqlsistic\dailyDBstatus.sql
)

C:\Tools\sqlcl\bin\sql %USRID%@sgcloud @c:\orawork\sqlsistic\asmusage.sql

del dailyDBrman.log
for %%c in %CONN% do (
  echo Connecting to %%c
  C:\Tools\sqlcl\bin\sql %USRID%@%%c @c:\orawork\sqlsistic\dailyDBbkup.sql
)
pause







