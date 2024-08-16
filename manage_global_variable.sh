#!/bin/bash

# Source the global configuration file
source global_config.sh

# Check if global__new_name has a value
if [ -z "$global__new_name" ]; then
    # If not, prompt the user to enter a new name
    read -p "Enter the new name for the copied directory (e.g., Portfolio.System.Prod31072024V0): " new_name    
    sed -i "s/^global__new_name=.*/global__new_name=\"$new_name\"/" global_config.sh
else
    # If it has a value, use the existing value
    echo "Using existing directory name: $global__new_name"
fi

if [ -z "$global__vps_server_pass" ]; then    
    read -p "Enter the VPS Server's Password: " vps_server_password    
    # Save the updated variable back to the config file
    sed -i "s/^global__vps_server_pass=.*/global__vps_server_pass=\"$vps_server_password\"/" global_config.sh
else
    # If it has a value, use the existing value
    echo "Password Filtered: **********"
fi