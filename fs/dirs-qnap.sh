#!/bin/sh

DRIVES="MD0 HDA HDB HDC HDD HDE HDF HDG HDH HDI HDJ HDK HDL HDM HDN HDO HDP HDQ HDR HDS HDT HDU HDV HDW HDX HDY HDZ"

for D in /etc /opt /root /tmp /usr/local /var; do
	echo $D
done

for R in $DRIVES; do
	for D in `ls -A /mnt/${R}_ROOT/ 2>/dev/null |grep -v ' ' |grep -v update_pkg$`; do
		echo /mnt/${R}_ROOT/$D
	done

	for D in `ls -A /share/${R}_DATA/ 2>/dev/null |grep -v ' ' |grep -v .qpkg$ |grep -v .sys_update_backup$`; do
		echo /share/${R}_DATA/$D
	done

	for D in `ls /share/${R}_DATA/.qpkg/ 2>/dev/null |grep -v ServerFarmer$`; do
		echo /share/${R}_DATA/.qpkg/$D
	done
done

for D in `ls /home/ 2>/dev/null`; do
	echo /home/$D
done

for D in `ls /mnt/ext/opt/ 2>/dev/null`; do
	echo /mnt/ext/opt/$D
done

for D in `ls /share/ 2>/dev/null |grep -v ' ' |egrep -v "(external|_DATA)$"`; do
	echo /share/$D
done

for D in `ls /share/external/ 2>/dev/null`; do
	echo /share/external/$D
done
