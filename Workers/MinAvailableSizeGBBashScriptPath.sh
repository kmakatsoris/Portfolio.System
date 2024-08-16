#!/bin/bash

# Define log file path
log_file="nlog-internal.log"

# Append header information to the log file
{
    echo "================================================================="
    echo "Welcome to the critical scenario where the server ran out of memory"
    echo "[Date: $(date +"%Y-%m-%d %H:%M:%S")]"
    echo "================================================================="
} >> "$log_file"

# [@FLAG: Adaptation]
system_path="../"

# Append system disk information to the log file
{
    echo "System's Disk Information:"
    df -h
} >> "$log_file"

# Change to the directory containing the docker-compose file
cd "$system_path" || {
    echo "Failed to change directory to $system_path. Exiting." >> "$log_file"
    exit 1
}

# Stop Docker containers
docker-compose down

if [ $? -ne 0 ]; then
    echo "docker-compose down FAILED. Exiting." >> "$log_file"
    exit 1
else
    echo "Stopped Containers From Running..."
fi

# Append success message to the log file
echo "MinAvailableSizaGBBashScript completed successfully." >> "$log_file"
