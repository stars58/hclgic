set JAVA_HOME=C:\Tools\sqldeveloper\jdk\jre\
set PATH=%JAVA_HOME%bin;%PATH%;

set USRID=user/passwrd
set CONN=(master,pac,sgcl)
)

del perfDBstatus.log
for %%c in %CONN% do (
  echo Connecting to %%c
  C:\Tools\sqlcl\bin\sql %USRID%@%%c @c:\orawork\sqlsistic\perfDBstatus.sql
)

pause







