#!/bin/sh

if [ -d /mnt/MD0_ROOT ] || [ -d /mnt/HDA_ROOT ]; then
	/opt/farm/ext/backup/fs/dirs-qnap.sh
else
	/opt/farm/ext/backup/fs/dirs-linux.sh
fi
