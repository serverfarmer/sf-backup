#!/bin/bash
. /opt/farm/scripts/functions.custom
. /opt/farm/ext/net-utils/functions
. /opt/farm/ext/backup/functions
# This script is intended to be used in all cases, where backup collector
# is unable to fetch backups from server (eg. for security reasons).

TMP="`local_backup_directory`"


if [ "$1" = "" ]; then
	echo "usage: $0 <user> <collector-hostname[:port]> <target-path> <ssh-key> [--all]"
	exit 1
elif ! [[ $1 =~ ^[a-z0-9]+$ ]]; then
	echo "error: parameter $1 not conforming user name format"
	exit 1
elif [ "`resolve_host $2`" = "" ]; then
	echo "error: parameter $2 not conforming hostname format, or given hostname is invalid"
	exit 1
elif [ ! -f $4 ]; then
	echo "error: ssh key $4 not found"
	exit 1
fi

if [ "$5" != "--all" ]; then
	files="`add_backup_extension $TMP/daily/'*'`"
else
	files="`add_backup_extension $TMP/daily/'*'` `add_backup_extension $TMP/weekly/'*'` `add_backup_extension $TMP/custom/'*'`"
fi

user=$1
server=$2
path=$3
sshkey=$4

if [ -z "${server##*:*}" ]; then
	host="${server%:*}"
	port="${server##*:}"
else
	host=$server
	port=22
fi

rsync -e "ssh -p $port -i $sshkey -o StrictHostKeyChecking=no -o PasswordAuthentication=no" -a $files $user@$host:$path/`date +%Y%m%d`
