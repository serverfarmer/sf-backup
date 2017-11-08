#!/bin/bash
. /opt/farm/scripts/functions.net
. /opt/farm/scripts/functions.custom
. /opt/farm/scripts/functions.keys
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
	echo "usage: $0 <collector-hostname[:port]> [--all]"
	exit 1
elif [ "`resolve_host $1`" = "" ]; then
	echo "error: parameter $1 not conforming hostname format, or given hostname is invalid"
	exit 1
fi

if [ "$2" != "--all" ]; then
	files="`add_backup_extension $TMP/daily/'*'`"
else
	files="`add_backup_extension $TMP/daily/'*'` `add_backup_extension $TMP/weekly/'*'` `add_backup_extension $TMP/custom/'*'`"
fi

server=$1
if [ -z "${server##*:*}" ]; then
	host="${server%:*}"
	port="${server##*:}"
else
	host=$server
	port=22
fi

sshkey=`ssh_management_key_storage_filename $host`
rsync -e "ssh -p $port -i $sshkey" -a $files root@$host:/srv/mounts/backup/remote/`hostname`/`date +%Y%m%d`
