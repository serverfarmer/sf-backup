#!/bin/bash
. /opt/farm/scripts/functions.custom
. /opt/sf-backup/functions

TMP="`local_backup_directory`"
DEST="$TMP/daily"

for D in `/opt/sf-backup/utils/directories.sh`; do
	if [ "$D" != "$TMP" ] && [ ! -f $D/.nobackup ] && [ ! -f $D/.weekly ]; then
		backup_directory $TMP $DEST $D
	fi
done
