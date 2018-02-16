#!/bin/sh
. /opt/farm/scripts/init

if [ "$OSTYPE" = "qnap" ]; then
	/opt/farm/ext/backup/fs/dirs-qnap.sh
else
	/opt/farm/ext/backup/fs/dirs-linux.sh
fi
