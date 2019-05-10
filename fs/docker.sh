#!/bin/sh

if [ -x /usr/bin/docker ]; then
	for VOL in `/usr/bin/docker volume list |grep ^local |awk '{ print $2 }'`; do
		/usr/bin/docker inspect $VOL |grep '"Mountpoint"' |awk '{ print $2 }' |sed -e s/\"//g -e s/,//g
	done
fi
