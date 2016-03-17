#!/bin/bash
. /opt/farm/scripts/functions.custom
. /opt/farm/ext/backup/functions

TMP="`local_backup_directory`"
DEST="$TMP/daily"

cd /tmp

if [ -x /usr/bin/psql ] && [ -x /usr/bin/pg_dump ]; then
	dbs=`pg_list_local_databases`
	for db in $dbs; do
		fname=`add_backup_extension postgres-$db.sql`
		sudo -u postgres pg_dump -c -i $db |`stream_handler` >$TMP/$fname
		mv -f $TMP/$fname $DEST/$fname 2>/dev/null
	done
fi
