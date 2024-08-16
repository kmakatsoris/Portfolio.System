#!/bin/bash

echo "======================================================"
echo "Welcome to Running Process"
echo "======================================================"

source manage_global_variable.sh
echo "The global directory name(global__new_name) is: $global__new_name"

# Define the local variables
remote_user="root"
remote_host="*******"
remote_path="/home/ubuntu/Workspace"
client_path="/Client"
WORKER_SCRIPT_PATH="$remote_path/$global__new_name/Workers/"
WORKER_SCRIPT_NAME="_run_worker.sh"

echo "remote_user: $remote_user"
echo "remote_host: $remote_host"
echo "remote_path: $remote_path"
echo "client_path: $client_path"
echo "WORKER_SCRIPT_PATH: $WORKER_SCRIPT_PATH"
echo "WORKER_SCRIPT_NAME: $WORKER_SCRIPT_NAME"

# SSH into the remote server to perform operations
sshpass -p "$global__vps_server_pass" ssh -T "$remote_user@$remote_host" << EOF

    cd $WORKER_SCRIPT_PATH
    echo "Working Directory is: $WORKER_SCRIPT_PATH"
    bash "$WORKER_SCRIPT_PATH$WORKER_SCRIPT_NAME"
    echo "Worker script has been running...[COMPLETED]"
    cd $remote_path/$global__new_name

    # Stop all running containers
    running_containers=\$(sudo docker ps -q)
    if [ -n "\$running_containers" ]; then
        echo "Stopping running containers..."
        sudo docker stop \$running_containers
    else
        echo "No running containers to stop."
    fi

    # Remove all containers
    all_containers=\$(sudo docker ps -a -q)
    if [ -n "\$all_containers" ]; then
        echo "Removing all containers..."
        sudo docker rm \$all_containers
    else
        echo "No containers to remove."
    fi

    # Clean up unused images, networks, and volumes
    echo "Pruning unused images, networks, and volumes..."
    sudo docker system prune --volumes --all -f

    # Prune specific items
    sudo docker image prune -a -f
    sudo docker volume prune -f
    sudo docker network prune -f
    echo "Removing the previous related to docker containers data...[COMPLETED]"

    # Navigate to the client's directory    
    cd "$remote_path/$global__new_name$client_path" || { echo "Directory $remote_path/$global__new_name$client_path not found."; exit 1; }
    echo "The client's directory is: \$(pwd)"
    echo "Navigating to the system's CLIENT's directory...[COMPLETED]"

    # Install npm packages
    sudo npm install
    echo "Installing the client's packages...[COMPLETED]"

    # Navigate to the parent directory
    cd ..
    echo "The system's directory is: \$(pwd)"
    echo "Navigating to the system's directory...[COMPLETED]"

    # Build and start Docker containers
    sudo docker-compose build --no-cache
    if [ \$? -ne 0 ]; then
        echo "docker-compose build --no-cache FAILED. Exiting."
        exit 1
    else
        echo "Building the System...[COMPLETED]"
    fi

    sudo docker-compose up
    if [ \$? -ne 0 ]; then
        echo "docker-compose up FAILED. Exiting."
        exit 1
    else
        echo "Starting the System...[COMPLETED]"
    fi    
EOF

echo "======================== Running Process Completed! ========================"
