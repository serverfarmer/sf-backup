#!/bin/bash
. /opt/farm/scripts/functions.custom
. /opt/farm/ext/backup/functions

TMP="`local_backup_directory`"
DEST="$TMP/daily"

warn="Using a password"

if [ -f /etc/mysql/debian.cnf ] && [ -f /var/run/mysqld/mysqld.pid ]; then
	pass="`cat /etc/mysql/debian.cnf |grep password |tail -n1 |sed s/password\ =\ //g`"
	if [ -f /etc/mysql/.nolock ]; then
		backup_mysql 127.0.0.1 3306 debian-sys-maint $pass mysql $TMP $DEST skip 2>&1 |grep -v "$warn"
	else
		backup_mysql 127.0.0.1 3306 debian-sys-maint $pass mysql $TMP $DEST 2>&1 |grep -v "$warn"
	fi

elif [ -f /usr/local/directadmin/conf/mysql.conf ]; then
	user="`cat /usr/local/directadmin/conf/mysql.conf |grep user= |tail -n1 |sed s/user=//g`"
	pass="`cat /usr/local/directadmin/conf/mysql.conf |grep passwd= |tail -n1 |sed s/passwd=//g`"
	backup_mysql 127.0.0.1 3306 $user $pass mysql $TMP $DEST 2>&1 |grep -v "$warn"
fi
