#!/bin/sh

rm -f /etc/cron.daily/backup
rm -f /etc/cron.weekly/backup

if grep -q /opt/sf-backup/cron /etc/crontab; then
	sed -i -e "/\/opt\/sf-backup\/cron/d" /etc/crontab
fi
