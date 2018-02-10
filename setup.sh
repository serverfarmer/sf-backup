#!/bin/bash
. /opt/farm/scripts/init
. /opt/farm/scripts/functions.custom


if [ "`getent passwd backup`" = "" ]; then
	echo "creating backup user and group"
	if [ "$OSTYPE" = "freebsd" ]; then
		pw groupadd backup -g 34
		pw useradd backup -u 34 -g backup -s /bin/sh -m
	elif [ "$OSTYPE" = "qnap" ]; then
		echo "backup:x:34:" >>/etc/config/group
		/usr/local/bin/useradd -u 34 -g backup -s /bin/sh -m backup
	else
		groupadd -g 34 backup
		useradd -u 34 -g backup -s /bin/sh -m backup
	fi
fi

if [ "$OSTYPE" = "debian" ] && [ "`getent passwd backup |cut -d: -f7`" = "/usr/sbin/nologin" ]; then
	echo "enabling rsync access for backup user"
	usermod -s /bin/sh backup
fi


if [ "$OSTYPE" = "qnap" ]; then
	path="/share/HDA_DATA/.qpkg/ServerFarmerBackup"
else
	path=`local_backup_directory`
fi

echo "setting up backup directories"
mkdir -p            $path/daily $path/weekly $path/custom
chmod 0700          $path/daily $path/weekly $path/custom
chown backup:backup $path/daily $path/weekly $path/custom

if [ "$OSTYPE" = "qnap" ]; then
	ln -s $path `local_backup_directory`
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


if [ "$HWTYPE" = "container" ] || [ "$HWTYPE" = "lxc" ]; then
	echo "skipping system backup configuration"
	exit 1
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

if ! grep -q /opt/farm/ext/backup/cron/fs- /etc/crontab; then
	echo "setting up filesystem backup scripts"
	echo "$((RANDOM%60)) 6 * * * root /opt/farm/ext/backup/cron/fs-daily.sh" >>/etc/crontab
	echo "$((RANDOM%60)) 6 * * 7 root /opt/farm/ext/backup/cron/fs-weekly.sh" >>/etc/crontab
fi
