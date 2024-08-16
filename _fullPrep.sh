#!/bin/bash

echo "======================================================"
echo "Welcome to the full System's Setup Process"
echo "======================================================"

remote_user="root"
remote_host="*****"
# ssh-keygen -R $remote_host -> Uncomment this and comment the if section if not working the below if section.
output=$(ssh -o StrictHostKeyChecking=ask -o BatchMode=yes $remote_host 2>&1)
# Check if the output contains the warning message
if echo "$output" | grep -q "WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!"; then
    echo "WARNING: Remote host identification has changed!"
    
    # Remove the old key from known_hosts
    ssh-keygen -R "$remote_host"

    # Optionally, you can reattempt the connection to add the new key
    echo "Reattempting connection to add the new key..."
    ssh "$remote_host"
else
    echo "No changes detected in remote host identification."
    # Continue with your script or operations
fi

# Imports
source manage_global_variable.sh
echo "The global directory name(global__new_name) is: $global__new_name"

chmod +x **/*.sh
echo "Providing executable grants to scripts...[COMPLETED]"

echo "======================================================" > global_diagnostics.txt
echo "Welcome to the full System's Setup Process" >> global_diagnostics.txt
echo "======================================================" >> global_diagnostics.txt

./__update_diagnostics.sh true "------------------------------ [INITIAL MEASUREMENT] --------------------------"

sudo apt-get install sshpass
echo "Installing dependencies...[COMPLETED]"

./__update_diagnostics.sh true "------------------------------ [INSTALLING ESSENTIAL DEPENDENCIES PREPARATION] --------------------------"

sudo ./_initialPrep.sh
./__update_diagnostics.sh true "------------------------------ [INITIAL PREPARATION] --------------------------"
echo "Executing _initialPrep.sh...[COMPLETED]"

# Check if script was successful
if [ $? -ne 0 ]; then
    echo "_initialPrep.sh failed. Exiting."
    exit 1
fi

sudo ./_prodPrep.sh
./__update_diagnostics.sh true "------------------------------ [PRODUCTION PREPARATION] --------------------------"
echo "Executing _prodPrep.sh...[COMPLETED]"

# Check if script was successful
if [ $? -ne 0 ]; then
    echo "_prodPrep.sh failed. Exiting."
    exit 1
fi

sudo ./_runPrep.sh
./__update_diagnostics.sh true "------------------------------ [RUNNING PREPARATION] --------------------------"
echo "Executing _runPrep.sh...[COMPLETED]"

# Check if script was successful
if [ $? -ne 0 ]; then
    echo "_runPrep.sh failed. Exiting."
    exit 1
fi

echo "All scripts executed successfully."


# Process the results file to format it into a table
echo "======================== Server's Initialization Process Completed! ========================"
echo "Results of df -h executions:"
echo "Filesystem    Size  Used Avail Use% Mounted on"
echo "-------------------------------------------------"
cat global_diagnostics.txt