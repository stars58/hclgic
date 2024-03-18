for db in `ps -ef | grep ora_pmon | grep -v grep |grep oracle | awk -F_ '{ print substr($3, 1, length($3))}'|sort`
do
export ORACLE_SID=$db
   dbn=${db:0:-1}
   # srvctl command

counter=$((counter+1))
echo $counter
case "$1" in
        instart)
            ;;
        instop)
            ;;
        instatus)
             srvctl status instance -d $dbn -i ${dbn}1
             srvctl status instance -d $dbn -i ${dbn}2
            ;;
        dbstart)
            ;;
        dbstop)
            ;;
        dbstatus)
            srvctl status database -d $dbn
esac
done

if [[ -z $1 ]];
then
    echo "No parameter passed. Possible option :(instatus,dbstatus)"
fi 
