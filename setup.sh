#!/bin/bash
. /opt/farm/scripts/init
. /opt/farm/scripts/functions.custom


if [ "$HWTYPE" = "container" ]; then
	echo "skipping system backup configuration"
	exit 1
fi

if [ "$OSTYPE" = "debian" ]; then
	owner="backup:backup"
else
	owner="root:root"
fi

path=`local_backup_directory`

echo "setting up backup directories"
mkdir -p     $path/daily $path/weekly $path/custom
chmod 0700   $path/daily $path/weekly $path/custom
chown $owner $path/daily $path/weekly $path/custom

echo "setting up filesystem backup scripts"
ln -sf /opt/sf-backup/cron/fs-daily.sh /etc/cron.daily/backup
ln -sf /opt/sf-backup/cron/fs-weekly.sh /etc/cron.weekly/backup

if [ -d /boot ] && [ ! -h /boot ] && [ ! -f /boot/.done ]; then
	echo "setting up default /boot directory backup policy"
	touch /boot/.weekly /boot/.done
fi

if ! grep -q /opt/sf-backup/cron/mysql.sh /etc/crontab && [ -f /etc/mysql/debian.cnf ]; then
	echo "setting up crontab entry for mysql backup"
	echo "$((RANDOM%60)) 4 * * * root /opt/sf-backup/cron/mysql.sh" >>/etc/crontab
fi

if ! grep -q /opt/sf-backup/cron/postgres.sh /etc/crontab && [ -x /usr/bin/psql ]; then
	echo "setting up crontab entry for postgres backup"
	echo "$((RANDOM%60)) 4 * * * root /opt/sf-backup/cron/postgres.sh" >>/etc/crontab
fi
