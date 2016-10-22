#!/bin/bash
. /opt/farm/scripts/init
. /opt/farm/scripts/functions.custom


if [ "$HWTYPE" = "container" ] || [ "$HWTYPE" = "lxc" ]; then
	echo "skipping system backup configuration"
	exit 1
fi

if [ "`getent passwd backup`" = "" ]; then
	echo "creating backup user and group"
	if [ "$OSTYPE" = "freebsd" ]; then
		pw groupadd backup -g 34
		pw useradd backup -u 34 -g backup -s /bin/sh -m
	else
		groupadd -g 34 backup
		useradd -u 34 -g backup -s /bin/sh -m backup
	fi
fi

path=`local_backup_directory`

echo "setting up backup directories"
mkdir -p            $path/daily $path/weekly $path/custom
chmod 0700          $path/daily $path/weekly $path/custom
chown backup:backup $path/daily $path/weekly $path/custom

if [ "$OSTYPE" = "freebsd" ] || [ "$OSTYPE" = "netbsd" ]; then
	mkdir -p   /var/lib
	chmod 0711 /var/lib
fi

if [ -d /boot ] && [ ! -h /boot ] && [ ! -f /boot/.done ]; then
	echo "setting up default /boot directory backup policy"
	touch /boot/.weekly /boot/.done
fi

if [ -h /etc/cron.daily/backup ]; then
	echo "removing deprecated links to filesystem backup scripts"
	rm -f /etc/cron.daily/backup
	rm -f /etc/cron.weekly/backup
fi

if ! grep -q /opt/farm/ext/backup/cron/fs- /etc/crontab; then
	echo "setting up filesystem backup scripts"
	echo "$((RANDOM%60)) 6 * * * root /opt/farm/ext/backup/cron/fs-daily.sh" >>/etc/crontab
	echo "$((RANDOM%60)) 6 * * 7 root /opt/farm/ext/backup/cron/fs-weekly.sh" >>/etc/crontab
fi

if ! grep -q /opt/farm/ext/backup/cron/mysql.sh /etc/crontab && [ -f /etc/mysql/debian.cnf ]; then
	echo "setting up crontab entry for mysql backup"
	echo "$((RANDOM%60)) 4 * * * root /opt/farm/ext/backup/cron/mysql.sh" >>/etc/crontab
fi

if ! grep -q /opt/farm/ext/backup/cron/postgres.sh /etc/crontab && [ -x /usr/bin/psql ]; then
	echo "setting up crontab entry for postgres backup"
	echo "$((RANDOM%60)) 4 * * * root /opt/farm/ext/backup/cron/postgres.sh" >>/etc/crontab
fi
