#!/bin/bash

echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo -e "  This script kill blocking/active session"
echo -e " " 
echo -e "     Database Instance :$ORACLE_SID"
echo -e "     Date              :$(printf  "$(date)")
echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"


if [[ -z $1 ]];
then
    echo "No parameter passed. List count of all blocking/active session"
	sqlplus / as sysdba @killsess.sql "l"
else
    echo "Parameter passed = $1"
	case $1 in
   "la") sqlplus / as sysdba @killsess.sql "la";;
   "lb") sqlplus / as sysdba @killsess.sql "lb";;
   "ka") sqlplus / as sysdba @killsess.sql "ka";;
   "kb") sqlplus / as sysdba @killsess.sql "kb";;
   "kj") sqlplus / as sysdba @killsess.sql "kJ";;
   *) echo "Sorry, wrong argument Valid selection (l la lb ka kb kj)";;
esac
fi
