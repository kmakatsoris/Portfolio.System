#!/bin/bash

echo "================================================================="
echo "Starting the WORKER Process."
echo "================================================================="

# Define directories and file names
PROJECT_DIR="."
BUILD_DIR="./bin/Release/net8.0/linux-x64/publish" # Adjust the .NET version and runtime identifier if needed
WORKER_DLL="Portfolio.Core.CleanAndBackup.Worker.dll"
OUTPUT_DIR="$BUILD_DIR"

# Define the output log file
LOG_FILE="worker_output.log"

# Navigate to the project directory
cd "$PROJECT_DIR" || { echo "Directory not found: $PROJECT_DIR"; exit 1; }

# Restore dependencies (if needed)
echo "Restoring project dependencies..."
dotnet restore

# Build the project
echo "Building the project..."
dotnet build -c Release

# Publish the project
echo "Publishing the project..."
dotnet publish -c Release -r linux-x64 --self-contained false -o "$BUILD_DIR"

# Check if the worker DLL exists
if [ ! -f "$BUILD_DIR/$WORKER_DLL" ]; then
    echo "Worker DLL not found: $BUILD_DIR/$WORKER_DLL"
    exit 1
fi

# Run the worker using dotnet in detached mode
echo "Running the worker in detached mode..."
nohup dotnet "$BUILD_DIR/$WORKER_DLL" > "$LOG_FILE" 2>&1 &

# Capture the PID of the worker process
WORKER_PID=$!

# Optionally, print a message when the worker starts
echo "Worker started in detached mode: $BUILD_DIR/$WORKER_DLL"
echo "Process ID: $WORKER_PID"
echo "Logs are being written to $LOG_FILE"

# Print the status of the worker process
ps aux | grep "$WORKER_DLL" | grep -v grep
