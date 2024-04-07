#!/bin/bash

# Function to set up environment and working directory
setup_environment() {
    # Display current user
    CURR_USER="$(whoami)"

    # Check if Oracle environment is set
    if [ -z "$ORACLE_SID" ]; then
        echo "Oracle environment is not set. Setting it using oraenv..."
        . /usr/local/bin/oraenv
    fi

    # Display Oracle environment
    #echo "Oracle SID: $ORACLE_SID"
    #echo "Oracle Home: $ORACLE_HOME"

    # Set working directory and make subdirectories GI and DB
    #export WORKING_DIR="/opt/oracle"
    #mkdir -p "$WORKING_DIR"/{GI,DB}
    #echo "Working directory set to: $WORKING_DIR"
}

# Function to check if Oracle database is RAC or single instance
check_rac() {
    echo "Checking if Oracle database is RAC or single instance..."
    if crsctl check cluster > /dev/null 2>&1; then
        DB_TYPE= "RAC."
    else
        DB_TYPE="Single"
    fi
}

# Function to check Oracle database PDB status
check_pdb_status() {
    echo "Checking Oracle database PDB status..."
    PDB_STATUS=$(sqlplus -S "/ as sysdba" <<EOF
    set heading off
    select name, open_mode from v\$pdbs;
    exit;
EOF
)
}

# Function to check Oracle OPatch version
check_opatch_version() {
    echo "Checking Oracle OPatch version..."
    OPATCH_VERSION=$("$ORACLE_HOME"/OPatch/opatch version)
}


# Function to check the operating system type
check_os() {
    if [[ $(uname) == "Linux" ]]; then
        OS_TYPE="Linux."
    elif [[ $(uname) == "SunOS" ]]; then
        OS_TYPE="Solaris."
    else
        OS_TYPE="Unknown OS"
    fi
}

INSTANCES=$(ps -ef | grep [o]ra_pmon | awk '{print $NF}'|sed -e 's/ora_pmon_//g'|grep -v sed|grep -v "s///g")

# Check if any instances are found
if [ -n "$instances" ]; then
    echo "Oracle Instances running: $instances"
else
    echo "No Oracle Instances running."
fi

display_output() {
   echo "Current User : $CURR_USER"
   echo "OS           : $OS_TYPE"
   echo "DB_TYPE      : $DB_TYPE"
   echo "All SID      : $INSTANCES"
   echo "Curr SID     : $ORACLE_SID"
   echo "Oracle Home  : $ORACLE_HOME"
   echo "OPatch ver   : $OPATCH_VERSION"
   echo "PDB status   : $PDB_STATUS"
}

# Main function
main() {
    setup_environment
    check_rac
    check_pdb_status
    check_opatch_version
    check_os
    display_output
}


# Execute main function
main

