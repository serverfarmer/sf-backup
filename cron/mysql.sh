#!/bin/bash
. /opt/farm/scripts/functions.custom
. /opt/farm/ext/backup/functions

TMP="`local_backup_directory`"
DEST="$TMP/daily"

if [ -f /etc/mysql/debian.cnf ] && [ -f /var/run/mysqld/mysqld.pid ]; then
	pass="`cat /etc/mysql/debian.cnf |grep password |tail -n1 |sed s/password\ =\ //g`"
	warn="Warning: Using a password on the command line interface can be insecure."
	if [ -f /etc/mysql/.nolock ]; then
		backup_mysql 127.0.0.1 3306 debian-sys-maint $pass mysql $TMP $DEST skip 2>&1 |grep -v "$warn"
	else
		backup_mysql 127.0.0.1 3306 debian-sys-maint $pass mysql $TMP $DEST 2>&1 |grep -v "$warn"
	fi
fi
