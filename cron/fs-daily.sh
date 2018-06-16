#!/bin/sh
. /opt/farm/scripts/functions.custom
. /opt/farm/ext/backup/functions
. /opt/farm/ext/keys/functions

TMP="`local_backup_directory`"
DEST="$TMP/daily"

for D in `/opt/farm/ext/backup/fs/detect.sh`; do
	if [ "$D" != "$TMP" ] && [ ! -f $D/.nobackup ] && [ ! -f $D/.weekly ]; then
		backup_directory $TMP $DEST $D
	fi
done
