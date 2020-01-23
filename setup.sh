#!/bin/bash
. /opt/farm/scripts/init
. /opt/farm/scripts/functions.custom


/opt/farm/scripts/setup/extension.sh sf-db-utils
/opt/farm/scripts/setup/extension.sh sf-net-utils
/opt/farm/scripts/setup/extension.sh sf-passwd-utils
/opt/farm/scripts/setup/extension.sh sf-binary-pgdump

if [ -s /etc/local/.config/backup.disable ]; then
	echo "skipping backup configuration, forced by backup.disable file"
	exit 0
fi

keyname=`/opt/farm/ext/keys/get-gpg-backup-key.sh`
if [ "$keyname" != "" ]; then
	/opt/farm/scripts/setup/extension.sh sf-gpg
fi

/opt/farm/ext/passwd-utils/create-group.sh backup 34
/opt/farm/ext/passwd-utils/create-user.sh backup backup 34 /var/backups /bin/sh

if [ "$OSTYPE" != "qnap" ]; then
	path=`local_backup_directory`
elif [ -d /share/HDA_DATA/.qpkg ]; then
	path=/share/HDA_DATA/.qpkg/ServerFarmer/backup
else
	path=/share/MD0_DATA/.qpkg/ServerFarmer/backup
fi

echo "setting up backup directories"
mkdir -p            $path/daily $path/weekly $path/custom
chmod 0700          $path/daily $path/weekly $path/custom
chown backup:backup $path/daily $path/weekly $path/custom

if [ "$OSTYPE" = "qnap" ]; then
	path2=`local_backup_directory`
	if [ ! -h $path2 ]; then
		ln -s $path $path2
	fi
fi


if ! grep -q /opt/farm/ext/backup/cron/mysql.sh /etc/crontab; then
	if [ -f /etc/mysql/debian.cnf ] || [ -d /usr/local/directadmin ]; then
		echo "setting up crontab entry for mysql backup"
		echo "$((RANDOM%60)) 4 * * * root /opt/farm/ext/backup/cron/mysql.sh" >>/etc/crontab
	fi
fi

if ! grep -q /opt/farm/ext/backup/cron/postgres.sh /etc/crontab && [ -x /usr/bin/psql ]; then
	echo "setting up crontab entry for postgres backup"
	echo "$((RANDOM%60)) 4 * * * root /opt/farm/ext/backup/cron/postgres.sh" >>/etc/crontab
fi

if ! grep -q /opt/farm/ext/backup/cron/mongodb.sh /etc/crontab && [ -x /usr/bin/mongo ] && [ -x /usr/bin/mongodump ]; then
	if [ -f /etc/mongodb.conf ] || [ -f /etc/mongod.conf ]; then
		echo "setting up crontab entry for mongodb backup"
		echo "$((RANDOM%60)) 4 * * * root /opt/farm/ext/backup/cron/mongodb.sh" >>/etc/crontab
	fi
fi

if ! grep -q /opt/farm/ext/backup/cron/docker.sh /etc/crontab && [ -x /usr/bin/docker ]; then
	echo "setting up crontab entry for docker backup"
	echo "$((RANDOM%60)) 5 * * * root /opt/farm/ext/backup/cron/docker.sh" >>/etc/crontab
fi

if [ "$HWTYPE" = "container" ] || [ "$HWTYPE" = "lxc" ]; then
	echo "skipping system backup configuration"
	exit 0
fi

if [ -f /etc/image-id ] && grep -q ami-ecs /etc/image-id; then
	echo "disabling backup of /var/lib/docker directory on Amazon ECS"
	date >/var/lib/docker/.nobackup
fi

if [ "$OSTYPE" = "freebsd" ] || [ "$OSTYPE" = "netbsd" ]; then
	mkdir -p   /var/lib
	chmod 0711 /var/lib
fi

if [ -d /usr/local/directadmin ] && [ ! -e /usr/local/bin/mysqldump ]; then
	echo "setting up directadmin mysqldump link"
	ln -s /usr/local/mysql/bin/mysqldump /usr/local/bin/mysqldump
fi

if [ -d /boot ] && [ ! -h /boot ] && [ ! -f /boot/.done ]; then
	echo "setting up default /boot directory backup policy"
	touch /boot/.weekly /boot/.done
fi

if [ -d /var/lib/mongodb ] && [ ! -h /var/lib/mongodb ] && [ ! -f /var/lib/mongodb/.done ]; then
	echo "setting up default /var/lib/mongodb directory backup policy"
	touch /var/lib/mongodb/.weekly /var/lib/mongodb/.done
fi

if ! grep -q /opt/farm/ext/backup/cron/fs- /etc/crontab; then
	echo "setting up filesystem backup scripts"
	echo "$((RANDOM%60)) 6 * * * root /opt/farm/ext/backup/cron/fs-daily.sh" >>/etc/crontab
	echo "$((RANDOM%60)) 6 * * 7 root /opt/farm/ext/backup/cron/fs-weekly.sh" >>/etc/crontab
fi
