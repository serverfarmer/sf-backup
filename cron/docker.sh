#!/bin/sh
. /opt/farm/scripts/functions.custom
. /opt/farm/ext/backup/functions

TMP="`local_backup_directory`"
DEST="$TMP/daily"

if [ -x /usr/bin/docker ]; then
	for VOL in `/usr/bin/docker volume list |grep ^local |awk '{ print $2 }'`; do
		D=`/usr/bin/docker inspect $VOL |grep '"Mountpoint"' |awk '{ print $2 }' |sed -e s/\"//g -e s/,//g`

		if [ -d $D ] && [ "`ls -A $D |grep -v hsperfdata_root`" != "" ] && [ ! -f $D/.nobackup ]; then
			backup_directory $TMP $DEST $D docker-$VOL.tar
		fi
	done
fi
