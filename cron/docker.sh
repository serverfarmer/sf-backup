#!/bin/sh
. /opt/farm/scripts/functions.custom
. /opt/farm/ext/backup/functions
. /opt/farm/ext/keys/functions

TMP="`local_backup_directory`"
DEST="$TMP/daily"

for D in `/opt/farm/ext/backup/fs/docker.sh`; do
	if [ -d $D ] && [ "`ls -A $D |grep -v hsperfdata_root`" != "" ] && [ ! -f $D/.nobackup ]; then
		backup_directory $TMP $DEST $D docker-$VOL.tar
	fi
done
