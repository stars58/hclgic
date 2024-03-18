set JAVA_HOME=C:\Tools\sqldeveloper\jdk\jre\
set PATH=%JAVA_HOME%bin;%PATH%;

set USRID=mainuser/passw0rd
set CONN=(galaxy,glxypac,jwpac,master,pac,sgcloud,spmaster,sptshub,sptspac,venetian,wkcd,wkcdpac)
)

del chkusername.log
for %%c in %CONN% do (
  echo Connecting to %%c
  C:\Tools\sqlcl\bin\sql %USRID%@%%c @c:\orawork\sqlsistic\chkusername.sql
)


pause







