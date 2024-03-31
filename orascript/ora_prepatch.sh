#!/bin/bash

# Function to display system information
display_system_info() {
    echo "Operating System: $(uname -s)"
    echo "Current User: $(whoami)"
    echo "ORACLE_SID: $ORACLE_SID"
    echo "Memory : $(free -m | awk '/Mem/{print $2 " MB"}')"
}

# Function to prompt user for variables
prompt_user() {
    read -p "Enter PSUBASE (default: /opt/oracle/patches): " PSUBASE
    PSUBASE=${PSUBASE:-/opt/oracle/patches}

    read -p "Enter PSUDIR (default: PSUJan2024): " PSUDIR
    PSUDIR=${PSUDIR:-PSUJan2024}
}

# Function to execute opatch utility
execute_opatch_util() {
    $ORACLE_HOME/OPatch/opatch util listorderedinactivepatches
    ## $ORACLE_HOME/OPatch/opatch util deleteinactivepatches
}

# Function to create directories and set permissions
create_directories() {
    mkdir -p "$PSUBASE/$PSUDIR/GI DB JAVA"
    chmod -Rf 777 "$PSUBASE/$PSUDIR"
}

# Function to unzip files
unzip_files() {
    for dir in GI DB JAVA; do
        unzip "$PSUBASE/$PSUDIR/$dir"*.zip -d "$PSUBASE/$PSUDIR/$dir"
    done
}


# Function to execute OPatch commands
spool_opatch() {
    cd $PSUBASE/$PSUDIR
    $ORACLE_HOME/OPatch/opatch version
    $ORACLE_HOME/OPatch/opatch lsinventory > GI_pre_lsinventory.log
    $ORACLE_HOME/OPatch/opatch lspatches >> GI_pre_lsinventory.log
}

# Function to check for Java component
check_java_component() {
    sqlplus -S / as sysdba <<EOF
SET LINESIZE 200
SELECT comp_name, version, status FROM dba_registry WHERE comp_name like '%JAVA%';
EXIT;
EOF
}

# Function to compile PDBS using catcon.pl
compile_pdbs() {
    cd $ORACLE_HOME/rdbms/admin
    $ORACLE_HOME/perl/bin/perl catcon.pl -d $ORACLE_HOME/rdbms/admin -l $PSUBASE/$PSUDIR -b utlrp utlrp.sql
}

# Function to upgrade OPatch
upgrade_opatch() {
    cd "$ORACLE_HOME"
    if [ "$(uname)" == "Linux" ]; then
        mv OPatch OPatch_Old
        unzip "/$PSUBASE/$PSUDIR/p6880880_190000_Linux-x86-64.zip"
    elif [ "$(uname)" == "SunOS" ]; then
        unzip "/$PSUBASE/$PSUDIR/p6880880_190000_SOLARIS64.zip"
    else
        echo "Unsupported OS"
        exit 1
    fi
}

# Main function
main() {
    display_system_info
    prompt_user

    echo "Select an option:"
    echo "1. Execute opatch utility"
    echo "2. Create directories and set permissions"
    echo "3. Unzip files"
    echo "4. spool opatch"
    echo "5. check_java_component"
    echo "6. compile_pdbs"
    echo "7. upgrade_opatch"

    read -p "Enter your choice: " choice

    case $choice in
        1) execute_opatch_util ;;
        2) create_directories ;;
        3) unzip_files ;;
        4) spool_opatch ;;
        5) check_java_component ;;
        6) compile_pdbs ;;
        7) upgrade_opatch ;;
        *) echo "Invalid choice"; exit 1 ;;
    esac


}

# Calling the main function
main
