#!/bin/sh
. /opt/farm/scripts/functions.custom
. /opt/farm/ext/backup/functions
. /opt/farm/ext/keys/functions

TMP="`local_backup_directory`"
DEST="$TMP/weekly"

for D in `/opt/farm/ext/backup/fs/detect.sh`; do
	if [ "$D" != "$TMP" ] && [ ! -f $D/.nobackup ] && [ -f $D/.weekly ]; then
		backup_directory $TMP $DEST $D
	fi
done

for D in `ls /home`; do
	if [ "`ls /home/$D`" != "" ] && [ ! -f /home/$D/.nobackup ]; then
		backup_directory $TMP $DEST /home/$D
	fi
done
