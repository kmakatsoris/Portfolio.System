#!/bin/bash

echo "======================================================"
echo "Welcome to Server's Initialization Process"
echo "======================================================"

source manage_global_variable.sh

# Define the local variables @Action: Change them
remote_user="root"
remote_host="*****"
remote_path="/home/ubuntu/Workspace"

echo "remote_user: $remote_user"
echo "remote_host: $remote_host"
echo "remote_path: $remote_path"

# Declare an array to store the results
# result=$(df -h | grep " /$") # df -h | awk '$2 == "/"' -> $2 == "/": This checks if the value in the second column ($2) is equal to /.    

# SSH commands (adjusted to ensure output is correctly formatted)
sshpass -p "$global__vps_server_pass" ssh -T "$remote_user@$remote_host" << EOF
    # Upgrade and update
    sudo apt upgrade -y
    sudo apt update -y
    result=\$(df -h | grep " /$")
    echo "\$result" >> /tmp/global_diagnostics_tmp.txt
    echo "Executing system's libraries UPGRADE & UPDATE -> [COMPLETED]"

    echo "======================================================"
    echo "Installing Docker Section"
    echo "======================================================"
    sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
    sudo apt update
    sudo apt install docker-ce -y
    sudo systemctl status docker
    result=\$(df -h | grep " /$")
    echo "\$result" >> /tmp/global_diagnostics_tmp.txt
    echo "Installing Docker Section -> [COMPLETED]"

    echo "======================================================"
    echo "Installing Latest Docker Compose Section"
    echo "======================================================"
    LATEST_DOCKERCOMPOSE_LTS_VERSION=\$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r '.tag_name')
    if [ -z "\$LATEST_DOCKERCOMPOSE_LTS_VERSION" ]; then
        echo "Failed to fetch the latest Docker Compose version. Using fallback version v2.29.1."
        LATEST_DOCKERCOMPOSE_LTS_VERSION="v2.29.1"
    else
        echo "Latest Docker Compose version is \$LATEST_DOCKERCOMPOSE_LTS_VERSION"
    fi

    sudo curl -L "https://github.com/docker/compose/releases/download/\$LATEST_DOCKERCOMPOSE_LTS_VERSION/docker-compose-\$(uname -s)-\$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    docker-compose --version
    result=\$(df -h | grep " /$")
    echo "\$result" >> /tmp/global_diagnostics_tmp.txt
    echo "Installing Latest Docker Compose Section -> [COMPLETED]"

    echo "======================================================"
    echo "Installing NPM and Node Section"
    echo "======================================================"
    sudo apt install nodejs npm -y  
    npm install react-scripts
    result=\$(df -h | grep " /$")
    echo "\$result" >> /tmp/global_diagnostics_tmp.txt
    echo "Installing NPM and Node Section -> [COMPLETED]"

    sudo apt-get update && sudo apt-get install -y dotnet-sdk-8.0
EOF

./__update_diagnostics.sh false "------------------------------ [INSIDE INITIAL PREPARATION] --------------------------"