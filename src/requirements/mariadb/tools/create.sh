#!/bin/sh

# Function to display usage of script
function usage ()
{
	echo "usage: $0 [DB-Name] [DB-User] [DB-Password]"
}

# Check arguments and assign if present
if [ $# -ne 3 ]; then
	usage
	exit 1
else
	DB_NAME=$1
	DB_USER=$2
	DB_PASS=$3
fi

DB_FILE=create.sql

# SQL Commands to create database
echo "CREATE DATABASE IF NOT EXISTS $DB_NAME;" > $DB_FILE
echo "CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASS';" >> $DB_FILE
echo "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%';" >> $DB_FILE
# Make root user useless
echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '12345';" >> $DB_FILE
echo "FLUSH PRIVILEGES;" >> $DB_FILE
