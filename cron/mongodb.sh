#!/bin/sh
. /opt/farm/scripts/functions.custom
. /opt/farm/ext/backup/functions
. /opt/farm/ext/keys/functions

TMP="`local_backup_directory`"
DEST="$TMP/daily"

if [ -x /usr/bin/mongo ] && [ -x /usr/bin/mongodump ]; then
	if [ -f /etc/mongodb.conf ] || [ -f /etc/mongod.conf ]; then
		DIR=`mktemp -d`
		cd $DIR

		if [ -f /etc/mongod.conf ]; then
			cat /etc/mongod.conf  |grep -v '^#' |grep -v "0.0.0.0" |tr ':' ' ' |tr '=' ' ' >conf.tmp
		else
			cat /etc/mongodb.conf |grep -v '^#' |grep -v "0.0.0.0" |tr ':' ' ' |tr '=' ' ' >conf.tmp
		fi

		ip="127.0.0.1"
		port="27017"

		if grep -q bind_ip conf.tmp; then
			ip=`cat conf.tmp |grep bind_ip |awk "{ print \\$2 }"`
		elif grep -q bindIp conf.tmp; then
			ip=`cat conf.tmp |grep bindIp |awk "{ print \\$2 }"`
		fi

		if grep -q port conf.tmp; then
			port=`cat conf.tmp |grep port |awk "{ print \\$2 }"`
		fi

		access="$ip:$port"
		dbs=`echo "show dbs" |mongo --quiet $access |grep -v "(empty)" |awk "{ print \\$1 }"`

		for db in $dbs; do
			mongodump --quiet --host $ip --port $port -d $db -o $DIR
			if [ -d $db ]; then
				fname=`add_backup_extension mongo-$db.tar`
				tar cf - $db 2>/dev/null |`stream_handler` >$TMP/$fname
				mv -f $TMP/$fname $DEST/$fname 2>/dev/null
			fi
		done

		cd /tmp
		rm -rf $DIR
	fi
fi
