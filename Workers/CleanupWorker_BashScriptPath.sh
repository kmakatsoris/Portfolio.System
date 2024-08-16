#!/bin/bash

echo "=================================================================" >> nlog-internal.log
echo "Welcome to the CLEAN UP scenario." >> nlog-internal.log
echo "[Date: $(date +"%Y-%m-%d %H:%M:%S")]" >> nlog-internal.log
echo "=================================================================" >> nlog-internal.log

# [@FLAG: Adaptation]
system_path="../"

cd $system_path || echo "Failed to navigate to system's directory" >> nlog-internal.log

find . -type f -name '*.log' -exec rm -f {} +
if [ $? -ne 0 ]; then
    echo "Removing all the .log files FAILED. Exiting." >> nlog-internal.log
    exit 1
else
    echo "Removed all the .log files."
fi


echo "Clean Up completed successfully." >> nlog-internal.log

