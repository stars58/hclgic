#!/bin/bash -u
# This script is for checking database performance
#  Owner:  


workdir=$( echo $0|sed 's/\/beholder_db_performance.sh//' )
hostName=$( hostname )
host=$( echo ${hostName}|cut -d'.' -f 1 )
SQLPLUS="sqlplus -s / as sysdba"
dblog="c:\temp\db_performance_validate.log"
tomail="n"

# run a sqlplus function
connect_to_sql () {
SQL_OUTPUT=$( $ORACLE_HOME/bin/sqlplus -s / as sysdba<< OCI
set heading off
set feedback off
$1
exit
OCI
)
echo "$SQL_OUTPUT"| /bin/grep -v \^$
}
is_cdb=$( connect_to_sql "select cdb from v\$database;" )

function pass () {

        echo -e "\E[0;32mPASSED\E[0;39m"

}


function fail () {

        failed=true
        if [[ -z ${1} ]]; then
          echo -e "\E[0;31mFAILED\E[0;39m"
        else
          echo -e "\E[0;31mFAILED\E[0;39m - "${1}
        fi
}

function output () {

        pad=$(printf '%0.1s' "."{1..80})
        string=${1}
        printf '%s' "${1} "
        echo -en $(printf '%*.*s' 0 $(( 80 - ${#string})) "${pad}")" "

}

function color_header () {
         if [[ -n ${1} ]];then
           echo -e "\n\E[1;35m${1}\n\E[0;39m"
         fi
}

function warn () {
        if [[ -z ${1} ]]; then
          echo -e "\E[0;33mWARNING\E[0;39m"
        else
          echo -e "\E[0;33mWARNING\E[0;39m - "${1}
        fi

}

check_aas() {
#color_header " Check AAS..." |tee -a ${dblog}
aas_cnt=$(connect_to_sql " select round(a.value) value from SYS.V\$SYSMETRIC a where a.METRIC_NAME in ('Average Active Sessions') and a.group_id=2;")
db_unique=$( connect_to_sql "select value from v\$parameter where name='db_unique_name';" )
if [[ "${aas_cnt}" -gt 20 ]]; then
  echo -e "AAS (${db_unique}): ${aas_cnt}" "\tHigh DB load - Pls Check." |tee -a ${dblog}
  tomail="y"
else
  echo -e "AAS (${db_unique}): ${aas_cnt}" "\tDB load OK." |tee -a ${dblog}
fi
}


# Verify it's logged in as oracle

date_today=$(printf  "$(date)")
host_name_desc=$(printf  "Host Name: ${host}")
num_sid_desc_e1=$(printf '%-123s' "Error: No instance is up running on ${host} but there is instance(s) registered in /etc/oratab.")
num_sid_desc_e2=$(printf '%-123s' "No instance created on ${host}.")
num_sid_desc_e3=$(printf '%-122s' " instance(s) found up and running on ${host}")
echo -e "     | ${date_today} |" | tee  $dblog
echo -e "     | ${host_name_desc}                     |\n" | tee -a $dblog
for dbhome in $( grep -v \^#  /var/opt/oracle/oratab|grep -i /oracle|grep -v ASM|grep -v MGMTDB|cut -d ':' -f 2 ); do
 break
done
export ORACLE_HOME=${dbhome}
export PATH=$ORACLE_HOME/bin:$PATH
export LD_LIBRARY_PATH=$ORACLE_HOME/lib

for dbsid in $( ps -ef | grep "pmon_" | grep -v grep |grep -v ASM |grep -v MGMTDB | cut -d'_' -f3 | grep -v ^+ ) ; do
export ORACLE_SID=${dbsid};
db_unique=$( connect_to_sql "select value from v\$parameter where name='db_unique_name';" )

# Check AAS session
check_aas
done
#mail out
if [[ "${tomail}" = "y" ]]; then
    echo | /opt/csw/bin/mailx -r noreply@sistic.com.sg  -s 'DB Load Alert (AAS)' vincentng@sistic.com.sg < ${dblog}
fi
stty sane

