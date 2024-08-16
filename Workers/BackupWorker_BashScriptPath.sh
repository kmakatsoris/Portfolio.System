#!/bin/bash

echo "=================================================================" >> nlog-internal.log
echo "Welcome to the BACKUP scenario." >> nlog-internal.log
echo "[Date: $(date +"%Y-%m-%d %H:%M:%S")]" >> nlog-internal.log
echo "=================================================================" >> nlog-internal.log

backend_path="../"
backup_path="../" 
mysql_path="../" 
strapi_path="../"
container_name="mysql-service"
db_user="admin_PortfolioDB"
db_name="PortfolioDB"
backup_filename="PortfolioDB_BackUp_$(date +"%d%m%Y").sql"
backup_folder="/initdb"
MYSQL_PASSWORD="******"

current_date=$(date +"%d%m%Y")

echo "backend_path: $backend_path"
echo "backup_path: $backup_path"
echo "mysql_path: $mysql_path"
echo "strapi_path: $strapi_path" 

rm -rf $backup_path/*-*-*
# Check if the directory is empty
if [ -z "$(ls -A "$backup_path/")" ]; then
    echo "Directory is empty. Creating ${backup_path}/${current_date}.0.tar.gz"
    touch "${backup_path}/${current_date}.0.tar.gz"
else
    echo "BackUp directory is not empty."
fi
# @CARE: If make changes here sync with the _prodPrep.sh to initialize Databases
latest_MySQL_version=$(ls -td $backup_path/* | awk -F/ '{print $3}' | awk -F. '{print $1 " " $2}' | awk '{print substr($1,7,4) substr($1,3,2) substr($1,1,2) "." $2}' | sort -k1,1r -k2,2n | awk -F. '{print  substr($1,5,2) substr($1,3,2)  "20"substr($1,1,2) "." $2}' | head -1) || echo "Failed to get MySQL BackUp LTS Version"
# SOS: ls -td $backup_path/* -> GETS All and files while ls -td $backup_path/*/ only the directories

# Create backup directories
mkdir -p $backup_path
mkdir -p $backup_path/$current_date || echo "Failed to creating current date directory" >> nlog-internal.log
mkdir -p $backup_path/$current_date/BackEnd || echo "Failed to creating current date BACKEND directory" >> nlog-internal.log
mkdir -p $backup_path/$current_date/MySQL || echo "Failed to creating current date MYSQL directory" >> nlog-internal.log
mkdir -p $backup_path/$current_date/Strapi || echo "Failed to creating current date STRAPI directory" >> nlog-internal.log

echo "Backing up backend logs..."
cp -r $backend_path/Logs $backup_path/$current_date/BackEnd/Logs || echo "Failed to copy Backend logs" >> nlog-internal.log

echo "Backing up MySQL directory..."
mkdir -p $backup_path/$current_date/MySQL$backup_folder
docker exec -i "$container_name" mysqldump -u "$db_user" -p "$MYSQL_PASSWORD" "$db_name" > "$backup_filename"

if [ $? -eq 0 ]; then
    echo "Database backup successful. File: $backup_filename"
else
    echo "Database backup failed."
    exit 1
fi
mv "$backup_filename" "$backup_path/$current_date/MySQL$backup_folder" || { echo "Failed to change directory to $backup_folder. Exiting."; exit 1; }

echo "Backing up Strapi directories and files..."
cp -r "$strapi_path/.tmp" $backup_path/$current_date/Strapi/.tmp || echo "Failed to copy strapi tmp" >> nlog-internal.log
cp -r "$strapi_path/database" $backup_path/$current_date/Strapi/database || echo "Failed to copy strapi database" >> nlog-internal.log
cp "$strapi_path/.env" $backup_path/$current_date/Strapi/.env || echo "Failed to copy strapi .env" >> nlog-internal.log

mkdir -p $backup_path/$current_date/Workers/
cp "nlog-internal.log" $backup_path/$current_date/Workers/ | mv $backup_path/$current_date/Workers/nlog-internal.log $backup_path/$current_date/Workers/worker-nlog-internal.log  || echo "Failed to copy WORKERS nlog-internal.log" >> nlog-internal.log

latest_MySQL_NEW_version=$(echo $latest_MySQL_version | awk -F. -v current_date=$(date +"%d%m%Y") '
{
    if ($1 == current_date) {
        $2 += 1;
        print $1 "." $2;
    } else {
        print current_date ".0";
    }
}'
)

tar -czvf $backup_path/${latest_MySQL_NEW_version}.tar.gz "$backup_path/${current_date}"
rm -rf $backup_path/$current_date

echo "Backup completed successfully." >> nlog-internal.log