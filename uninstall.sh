#!/bin/sh

rm -f /etc/cron.daily/backup
rm -f /etc/cron.weekly/backup

if grep -q /opt/farm/ext/backup/cron /etc/crontab; then
	sed -i -e "/\/opt\/farm\/ext\/backup\/cron/d" /etc/crontab
fi
