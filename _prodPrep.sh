#!/bin/bash

echo "======================================================"
echo "Welcome to Preparation Process"
echo "======================================================"

source manage_global_variable.sh
echo "The global directory name(global__new_name) is: $global__new_name"

# Define the local variables @Action: Change them
#[@FLAG: Modify]
remote_user="root"
remote_host="*****"
remote_path="/home/ubuntu/Workspace"
local_folder_name="Portfolio.System"
mysql_path="MySQL"
backup_path="BackUp"
mySQL_initdb="initdb"
tarball_name="$global__new_name.tar.gz"
paths=(
    "SystemStructure.png",
    "StrapiExport.png"
    "<EDIT>.png"
)

echo "remote_user: $remote_user"
echo "remote_host: $remote_host"
echo "remote_path: $remote_path"
echo "local_folder_name: $local_folder_name"
echo "tarball_name: $tarball_name"
paths_string=$(IFS=, ; echo "${paths[*]}")
echo "Custom Files or Directories to Remove: $paths_string"

# Initialize MySQL
latest_MySQL_version=$(ls -td $backup_path/* | awk -F/ '{print $2}' | awk -F. '{print $1 " " $2}' | awk '{print substr($1,7,4) substr($1,3,2) substr($1,1,2) "." $2}' | sort -k1,1r -k2,2n | awk -F. '{print  substr($1,5,2) substr($1,3,2)  "20"substr($1,1,2) "." $2}' | head -1) || echo "Failed to get MySQL BackUp LTS Version"
mkdir -p $mysql_path
rm -rf $mysql_path/*
cp -r $backup_path/$latest_MySQL_version.tar.gz $mysql_path/
tar -xzvf $mysql_path/$latest_MySQL_version.tar.gz
mv $latest_MySQL_version/$mysql_path/$mySQL_initdb $mysql_path
rm -rf $latest_MySQL_version
rm -rf $mysql_path/$latest_MySQL_version.tar.gz

# Navigate to the parent directory
cd .. || { echo ********************************; echo "Failed to change directory"; echo ********************************; exit 1; }

# Copy the directory
sudo cp -r Portfolio.System "$global__new_name" || { echo ********************************; echo "Failed to copy directory"; echo ********************************; exit 1; }

echo "Directory copied to $global__new_name...[COMPLETED]"

# Navigate into the new directory
cd "$global__new_name" || { echo ********************************; echo "Failed to change directory"; echo ********************************; exit 1; }

# Remove specific directories
sudo find . -type d \( -name 'bin' -o -name 'obj' -o -name '.git' -o -name '.vscode' -o -name 'Logs' -o -name 'logs' \) -exec rm -rf {} +
echo "Removing specific directories.... (E.g. bin, obj, .git, .vscode, Logs, logs) [COMPLETED]"

for path in "${paths[@]}"; do
    if [ -e "$path" ]; then        
        echo "Deleting: $path"            
        sudo rm -rf "$path"        
        if [ $? -eq 0 ]; then
            echo "Successfully deleted: $path"
        else
            echo "Failed to delete: $path"
        fi
    else
        echo "Path does not exist: $path"
    fi
done
echo "Deleting custom/run time specified files and directories. [COMPLETED]"

# Remove specific files
sudo find . -type f -name '*.md' -exec rm -f {} +
sudo find . -type f -name '.gitignore' -exec rm -f {} +
echo "Removing specific files.... (E.g. *.md, .gitignore) [COMPLETED]"

# Remove node_modules directories
sudo find . -type d -name 'node_modules' -exec rm -rf {} +
echo "Removing node_modules directories...[COMPLETED]"

cd .. || { echo "Failed to change directory to parent"; exit 1; }
sudo chmod -R 777 "$global__new_name" || { echo ********************************; echo "Failed to change permissions"; echo ********************************; exit 1; }
echo "Changing permissions to the new application...[COMPLETED]"

# Verify the directory exists before creating the tarball
if [ ! -d "$global__new_name" ]; then
    echo "Directory $global__new_name does not exist. Cannot create tarball."
    exit 1
fi

# Create a tarball of the new directory
sudo tar -czvf "$tarball_name" "$global__new_name" || { echo ********************************; echo "Failed to create tarball"; echo ********************************; exit 1; }
echo "Tarball creation...[COMPLETED]"

# SSH into the remote server to create the path where the data would be conveyed
sshpass -p "$global__vps_server_pass" ssh -T "$remote_user@$remote_host" << EOF
    [ -d "$remote_path" ] && rm -rf "$remote_path"
    sudo mkdir -p "$remote_path" || { echo ********************************; echo "Failed to create the directory on remote server"; echo ********************************; exit 1; }
    echo "Directory creation...[COMPLETED]"
EOF

# Transfer the tarball to the remote server
scp "$tarball_name" "$remote_user@$remote_host":"$remote_path" || { echo ********************************; echo "Failed to transfer tarball"; echo ********************************; exit 1; }
echo "Tarball transfer...[COMPLETED]"

# SSH into the remote server to prepare and extract the tarball
echo "Connecting to remote server..."
# SSH into the remote server to navigate, extract, and clean up
sshpass -p "$global__vps_server_pass" ssh -T "$remote_user@$remote_host" << EOF
    cd "$remote_path"
    if [ \$? -ne 0 ]; then
        echo ********************************
        echo "Failed to change directory on remote server"
        echo ********************************
        exit 1
    fi
    echo "Directory navigation...[COMPLETED]"
    
    sudo tar -xzvf "$tarball_name"
    if [ \$? -ne 0 ]; then
        echo ********************************
        echo "Failed to extract tarball"
        echo ********************************
        exit 1
    fi
    echo "Tarball extraction...[COMPLETED]"
    
    sudo rm -rf "$tarball_name"
    if [ \$? -ne 0 ]; then
        echo ********************************
        echo "Failed to cleanup tarball"
        echo ********************************
        exit 1
    fi
    echo "Cleanup tarball...[COMPLETED]"
EOF

# Clean up local tarball
sudo rm "$tarball_name" || { echo ********************************; echo "Failed to remove local tarball"; echo ********************************; exit 1; }
sudo rm -rf "$global__new_name" || { echo ********************************; echo "Failed to remove Application Copy"; echo ********************************; exit 1; }
echo "Local tarball & Copy Application cleanup...[COMPLETED]"

echo "======================== Preparation Process Completed! ========================"
