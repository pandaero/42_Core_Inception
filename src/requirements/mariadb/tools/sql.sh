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

# SQL Commands to create database
echo "CREATE DATABASE IF NOT EXISTS $DB_NAME;" > db.sql
echo "CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASS';" >> db.sql
echo "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%';" >> db.sql
# Make root user useless
echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '12345';" >> db.sql
echo "FLUSH PRIVILEGES;" >> db.sql

# Run SQL script
mariadb < db.sql
