#!/bin/sh

for D in /etc /root /boot /var/log /var/cache/farm; do
	echo $D
done

if [ ! -f /var/www/.subdirectories ]; then
	echo /var/www
else
	for D in `ls /var/www 2>/dev/null`; do
		echo /var/www/$D
	done
fi

for D in `ls /data 2>/dev/null`; do
	echo /data/$D
done

for D in `ls /opt 2>/dev/null |egrep -v "^(farm|misc|warfare)$"`; do
	echo /opt/$D
done

for D in `ls /srv 2>/dev/null |egrep -v "^(apps|chunks|cifs|imap|isync|mounts|nfs|sites)$" |grep -v ^rsync`; do
	echo /srv/$D
done

for D in `ls /srv/apps 2>/dev/null`; do
	echo /srv/apps/$D
done

for D in `ls /srv/sites 2>/dev/null`; do
	echo /srv/sites/$D
done

for D in `ls /var/lib/lxc 2>/dev/null`; do
	echo /var/lib/lxc/$D
done

for D in `ls -F /var/lib |grep / |egrep -v "^(AccountsService|alsa|alternatives|apparmor|apt|apt-xapian-index|aptitude|belocs|aspell|binfmts|clamav|colord|cron-apt|dictionaries-common|dkms|doc-base|emacsen-common|gconf|gems|ghc|ghostscript|haproxy|initramfs-tools|iptotal|iptraf|ispell|libreoffice|libxml-sax-perl|lightdm|lightdm-data|locales|logcheck|logrotate|lxc|lxcfs|lxd|lxdm|man-db|mdadm|mibs|mlocate|monit|mplayer|mysql|nfs|nginx|ntp|ntpdate|openbox|plymouth|polkit-1|postfix|postgresql|python|python-support|resolvconf|rfkill|scrollkeeper|sepolgen|setroubleshoot|sgml-base|smartmontools|snapd|snmp|stateless|sudo|systemd|tex-common|texmf|ubiquity|ubuntu-drivers-common|ubuntu-release-upgrader|udisks2|update-manager|update-notifier|update-rc.d|urandom|upower|ureadahead|usbutils|VBoxGuestAdditions|vim|xfonts|xkb|xml-core)/$" |cut -d/ -f1`; do
	echo /var/lib/$D
done

for D in lxc ntp omc pam php pve ssh ssl zsh dbus gvfs keys nmap pear qemu rssh gnupg mysql samba scout YaST2 augeas config debsig fedora opensc polkit vyatta adduser cluster debconf elastix jenkins openlmi openvpn Pegasus postfix redland xtables zentyal apparmor keyrings ontology openldap sendmail susehelp sysmerge virtuoso zenbuntu a2billing glusterfs heartbeat openattic pkgconfig shorewall open-cobol postgresql spamassassin SuSEfirewall2 mobile-broadband ca-certificates perl5/site perl5/vendor perl5/EBox perl5/PVE; do
	echo /usr/share/$D
done

for D in php ssl ctasd ctipd vzctl mailman savapi3 sysctl.d perl5/site perl5/vendor; do
	echo /usr/lib/$D
done

if [ -d /usr/lib64 ] && [ ! -h /usr/lib64 ]; then
	for D in vzctl perl5/site perl5/vendor; do
		echo /usr/lib64/$D
	done
fi

for D in `ls / |egrep -v "^(bin|boot|cgroup|data|dev|etc|home|initrd.img|lib|lib32|lib64|libdata|libexec|livecd|lost\+found|media|mnt|opt|proc|rescue|root|run|sbin|selinux|srv|sys|tmp|usr|var|vmlinuz)$"`; do
	echo /$D
done

for D in `ls /usr |egrep -v "^(X11|X11R6|X11R7|bin|doc|drivers|games|include|info|kerberos|lib|lib32|lib64|libdata|libexec|local|man|ports|sbin|share|spool|src|tmp|x86_64-slackware-linux|x86_64-suse-linux)$"`; do
	echo /usr/$D
done

for D in `ls /usr/local 2>/dev/null |egrep -v "^(bin|games|include|lib|man|sbin|share)$"`; do
	echo /usr/local/$D
done

for D in `ls /usr/src 2>/dev/null |egrep -v "^(kernels|linux)$" |egrep -v "^(kernel-devel-|linux-)"`; do
	echo /usr/src/$D
done
