#!/bin/bash

# Check if an argument was passed, if not, set a default value for the separator
if [ -z "$1" ]; then
    SEPARATOR="------------------------------ [DEFAULT SEPARATOR] --------------------------"
else
    SEPARATOR="$1"
fi

# Initialize a temporary array to hold processed results
declare -a df_results=()

# Read and parse the results
while IFS= read -r line; do
    # Check if the line is not empty and does not start with "Filesystem" or "Mounted on"
    if [[ -n "$line" && "$line" != "Filesystem"* && "$line" != "Mounted on" ]]; then
        df_results+=("$line")
    fi
done < ./global_diagnostics_tmp.txt

# Use the separator passed as an argument
./__add_separator_diagnosticsConfig.sh "$SEPARATOR"
