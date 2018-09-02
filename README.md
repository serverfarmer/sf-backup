# Server Farmer backup architecture

### Overview

Distributed backup is one of the key functionalities of Server Farmer.

All hosts with installed Server Farmer, unless explicitly disabled, are doing their own backup (to specified directory on local drive), which is then pulled using `scp` by special host named *backup collector* (which is responsible for long-term backup storage).

*This part of backup documentation describes only local aspects. See `sf-backup-collector` repository for details about backup transfer, central storage etc.*


### Backup sources

There are several types of backup sources:

##### local directories

`fs/` directory contains scripts responsible for detection, which directories should be backed up, and which not. The general idea is that system directories should be skipped as useless and just wasting space.

There are 5 conditions, under which particular directory will be backed up:
- is not a backup target (sub)directory (to avoid backup loops)
- was listed by `fs/detect.sh` script
- is not empty
- doesn't contain `.nobackup` file
- is a physical directory, not a directory symlink

##### local MySQL databases

`db-utils` extension is responsible for detecting MySQL configurations, that allow automatic backup. Right now, there are 2 supported configuration styles:

- Debian (used also on Ubuntu and several other Debian clones) - where `/etc/mysql/debian.cnf` file contains database login and password
- DirectAdmin panel - where `/usr/local/directadmin/conf/mysql.conf` file contains database login and password

MySQL backup logic is written is reusable way, so you can easily write your own backup scripts, backing up eg. databases in Docker containers, or running on other hosts, by using `backup_mysql` function from `/opt/farm/ext/backup/functions` script.

All databases are dumped into separate `mysql-*.sql` files, as well as grants list, which is dumped to `mysql-grants.sql` file (`mysql` prefix can be changed in your custom scripts).

**Important note**: by default, MySQL backup is done in `FLUSH TABLES WITH READ LOCK` mode. This is perfectly fine, if you have small or medium databases, that dump in seconds or less. However, if you have really big database(s), it's better to disable cron entry `/opt/farm/ext/backup/cron/mysql.sh` (comment it out, not delete!) and write custom backup script (`backup_mysql` function takes 8th argument, that can disable table locking).

##### local Postgres databases

Postgres backup requires that peer authentication for `postgres` user is enabled. Similar to MySQL, all databases are dumped into separate files.

##### local MongoDB databases

MongoDB backup supports 2 configuration styles, with `/etc/mongodb.conf` and `/etc/mongod.conf` configuration files, with either `bind_ip` or `bindIp` configuration directives - so it covers all MongoDB versions since 2.x to the current one.

Other requirements:

- `/usr/bin/mongodump` file is present (in some Linux distributions, it's a part of separate package, eg. `mongodb-clients` or `mongo-tools`)
- MongoDB daemon is properly configured to listen either on `0.0.0.0`, `127.0.0.1` or one of local IP addresses (primary for each network interface device)
- on port 27017, or other explicitly set in config file
- MongoDB doesn't require authentication (which is the default mode)

Empty databases are skipped, and all other ones are exported in BSON format, then packed into `.tar` archives.

##### other databases

Direct support for other database types is not planned, since their data directories are detected and backed up just like other local directories. In some edge cases, you may need to adjust some settings related to saving data to disk.


### Backup ranges

#### daily

Is the primary backup range. Most directories, and all databases, work in `daily` mode.

#### weekly

These directories are backed up just once a week (on Sundays):
- `/home` subdirectories
- `/boot` directory
- directories with `.weekly` file inside

#### custom

This mode is not executed automatically by default. It is a way for you to implement custom backup schemes, eg. to backup **huge** databases, mailboxes or other problematic data sources, when the whole backup process is divided into several days/phases.


### Backup target directory

All backups are first created in local directory, by default in `/backup` (it can be configured using `local_backup_directory` function in `scripts/functions.custom` inside Server Farmer main repository.

This directory acts as a temporary directory, and also contains 3 subdirectories: `daily`, `weekly` and `custom`. Temporary archive is created in `/backup`, and when finished, moved to eg. `/backup/daily`.


### Magic files

There are 3 "magic" files, that are recognized by Server Farmer:

- `.weekly` causes backup scripts to skip this directory in `daily` mode (backup is done only on Sundays)
- `.nobackup` completely removes parent directory from backup
- `.subdirectories` - works only inside `/var/www` directory, causes backing up each `/var/www` subdirectory separately, instead of just `/var/www` as a whole


### Backup encryption

Created backup archives are compressed and possibly encrypted on-the-fly (during creation), so nobody can see their contents. GPG encryption is used for that.

To enable encryption, you need to make the following changes in your `sf-keys` repository fork:

- generate new GPG RSA key pair (manually) and store the private key in a safe place
- edit `functions` file and add your key ID to `gpg_backup_key` function
- add your key to `gpg/` directory (filename must match key ID with `.pub` extension)
- commit and push changes
- re-execute `/opt/farm/setup.sh` on all your farm

This will install `sf-gpg` extension, and execute GPG key setup, so it will require your attention and manual help (only once per host).

If `gpg_backup_key` function returns nothing, backups are not encrypted - just compressed with `gzip -c9`.


### Disabling backup

You can completely disable backup on current host by creating `/etc/local/.config/backup.disable` file. It will prevent `sf-backup` extensions from continuing setup, however if this file is created after setup, it's not enough, and you have to disable cron scripts using by running `/opt/farm/ext/backup/uninstall.sh` script.


### Backup of LXC and other container types

There are multiple types of paravirtualization mechanisms: Docker, LXC, OpenVZ, Xen PV, nspawn, linux-vserver etc.

This is how Server Farmer treats them:

1. LXC is a normal, active platform, on which Server Farmer can be installed and used, similar to any other virtual/physical machine - however:
- backup of local directories on LXC is skipped
- local databases are still backed up
- parent host detects subdirectories of `/var/lib/lxc` directory as source directories to backup (each container is backed up to separate archive)
- LXC hosts are not registered to *backup collector* - instead, backup collector pulls backups of the whole containers from parent host

2. Docker and OpenVZ containers are supported as passive containers (`sf-execute` command on *farm manager* can execute commands on them, but installing Server Farmer on them is unsupported. These types of containers are backed up as a whole `/var/lib/docker` or `/var/lib/vz` directory (all containers in single archive).

3. Other types of containers (Xen PV, nspawn, linux-vserver etc.) are unsupported and backed as a whole local directory.
