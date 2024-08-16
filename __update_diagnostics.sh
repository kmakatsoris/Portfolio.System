#!/bin/bash

# Load global variables
source manage_global_variable.sh
echo "The global directory name (global__new_name) is: $global__new_name"

# Variables for remote connection
remote_user="root"
remote_host="*****"
remote_path="/home/ubuntu/Workspace"
echo "remote_user: $remote_user"
echo "remote_host: $remote_host"
echo "remote_path: $remote_path"

# Check if the first argument is "true"
if [ "$1" = "true" ]; then
    echo "Executing commands on the remote server..."
    
    sshpass -p "$global__vps_server_pass" ssh -T "$remote_user@$remote_host" << 'EOF'
        result=$(df -h | grep " /$")
        echo "$result" >> /tmp/global_diagnostics_tmp.txt
EOF
fi

# Retrieve the results from the remote server to the local machine
sshpass -p "$global__vps_server_pass" scp "$remote_user@$remote_host:/tmp/global_diagnostics_tmp.txt" ./global_diagnostics_tmp.txt

# Clear the content of the remote diagnostics file
sshpass -p "$global__vps_server_pass" ssh -T "$remote_user@$remote_host" <<EOF
    echo '' > /tmp/global_diagnostics_tmp.txt
EOF

# Pass the second argument (separator) to the __save_diagnostics_to_file.sh script
./__save_diagnostics_to_file.sh "$2"
