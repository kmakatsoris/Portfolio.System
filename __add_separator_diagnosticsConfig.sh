#!/bin/bash

# Check if exactly one argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <separator-text>"
    exit 1
fi

separator_text="$1"
tmp_file="global_diagnostics_tmp.txt"
dest_file="global_diagnostics.txt"

# Check if the temporary file exists
if [ ! -f "$tmp_file" ]; then
    echo "Temporary file $tmp_file does not exist."
    exit 2
fi

# Append the separator text to the destination file
echo "$separator_text" >> "$dest_file"

# Append the content of the temporary file to the destination file
cat "$tmp_file" >> "$dest_file"

# Clear the content of the temporary file
> "$tmp_file"

echo "Content has been added to $dest_file and $tmp_file has been cleared."
