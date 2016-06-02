#!/bin/bash
. /opt/farm/scripts/functions.custom
# This script is intended to be used only on farm manager, when:
# - backup collector role is delegated to another server
# - backup collector doesn't have ssh key to farm manager
# - farm manager has ssh root key for backup collector
#
# Such scheme can occur eg. in increased-security-farms (along with backup
# encryption), where farm manager is operated only by carefully selected
# staff, while backup collector has wider access.

TMP="`local_backup_directory`"


if [ "$1" = "" ]; then
	echo "usage: $0 <collector-hostname> [--all]"
	exit 1
elif ! [[ $1 =~ ^[a-z0-9.-]+[.][a-z0-9]+([:][0-9]+)?$ ]]; then
	echo "error: invalid backup collector hostname"
	exit 1
elif [ "`getent hosts $1`" = "" ]; then
	echo "error: host $1 not found"
	exit 1
fi

if [ "$2" != "--all" ]; then
	files="`add_backup_extension $TMP/daily/'*'`"
else
	files="`add_backup_extension $TMP/daily/'*'` `add_backup_extension $TMP/weekly/'*'` `add_backup_extension $TMP/custom/'*'`"
fi

dt=`date +%Y%m%d`
host=`hostname`
sshkey=`ssh_management_key_storage_filename $1`
rsync -e "ssh -i $sshkey" -a $files root@$1:/srv/mounts/backup/remote/$host/$dt
