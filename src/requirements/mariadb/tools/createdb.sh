#!/bin/sh

# CHANGE THESE VALUES
ROOT_PASS=ROOTPASS
DB_NAME=wordpress
DB_USER=wordpress
DB_PASS=PASS

# Check mySQL running, start it if not.
if [ ! -d "/varl/lib/mysql/mysql" ]; then
	chown -R mysql:mysql /var/lib/mysql
	mysql_install_db --basedir=/usr --datadir=/var/lib/mysql --user=mysql
	tempfile=`mktemp`
	if [ ! -f "$tempfile" ]; then
		return 1
	fi
fi

# Make Wordpress database script
if [ ! -d "/var/lib/mysql/$DB_NAME" ]; then
	# Prepare SQL script to create Wordpress database
	DB_FILE=$( dirname -- "$0" )/createdb.sql
	cat << EOF > /$DB_FILE
USE mysql;
FLUSH PRIVILEGES;
DELETE FROM mysql.user WHERE User='';
DROP DATABASE test;
DELETE FROM mysql.db WHERE Db='test';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
ALTER USER 'root'@'localhost' IDENTIFIED BY '$ROOT_PASS';
CREATE DATABASE $DB_NAME CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER '$DB_USER'@'%' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%';
FLUSH PRIVILEGES;
EOF
	# Run database creation SQL
	/usr/bin/mariadbd --user=mysql --bootstrap < $DB_FILE
	rm -f $DB_FILE
fi
