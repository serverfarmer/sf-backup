#!/bin/sh
. /opt/farm/scripts/functions.custom
. /opt/farm/ext/backup/functions

TMP="`local_backup_directory`"
DEST="$TMP/daily"

cd /tmp

if [ "`which psql 2>/dev/null`" != "" ] && [ "`which pg_dump 2>/dev/null`" != "" ] && [ "`getent passwd postgres`" != "" ]; then
	dbs=`sudo -u postgres psql -l -q -X 2>/dev/null |awk "{ print \\$1 }" |grep ^[a-zA-Z] |grep -v ^List$ |grep -v ^Name$ |grep -v ^template[0-9]$`
	for db in $dbs; do
		fname=`add_backup_extension postgres-$db.sql`
		sudo -u postgres pg_dump -c $db |`stream_handler` >$TMP/$fname
		mv -f $TMP/$fname $DEST/$fname 2>/dev/null
	done
fi
