# Simple FreeBSD rsync based backup bot

This is a simple script that can be launched via ```periodic```
or ```cron``` that performs periodic backup jobs. When launched
via ```periodic``` this plays well with the [periodic snapshot
scripts](https://github.com/tspspi/simpleFreeBSDPeriodicZFSSnapshotScripts)
to additionally snapshot after or before every ```rsync``` run.

The script uses a simple SSH pubkey to authenticate against the
remote machine and pulls the configured paths in a local filesystem
hierarchy.

The script can be stored anywhere (for example at ```/usr/local/bin/run_backup.sh```
or at the ```/etc/periodic``` hierarchy). It accepts the run type
(daily, weekly, monthly) that will be matched against configuration.

The configuration happens in ```/etc/rsyncup.conf```. The following
options are supported:

* ```rsyncup_enable="YES"``` enables processing of the configuration and
  enabled the backup process
* ```rsyncup_jobs``` contains a space separated list of jobs to execute.
  Each job consists of (currently) 5 parameters that are separated by
  colons ```:```:
   * The first is the ```user@host``` as well as the remote directory
     that should be backed up
   * The second is the local directory onto which one wants to sync
   * The third specifies the type of the backup (daily, weekly, monthly, etc.)
   * The last allows to specify the ```--rsync-path``` argument which is
     required when backing up Windows machines under some circumstances.
* ```rsyncup_logfile``` allows to override the logfile used for
  coarse logging
* ```rsyncup_debuglogfile``` allows to override the logfile used for
  detailed debug logging.

Example for the ```rsyncup_jobs``` variable:

```
rsyncup_jobs="example@192.158.1.38:/home/example/;/backups/example/;daily; winexample@192.158.1.39:/c/users/winexample/;/backups/winexample/;daily;c:/mingw/msys/1.0/bin/rsync"
```

## Run from periodic

To run the script from periodic one can simply add
an ```/etc/periodic/daily/900.backup``` shellscript:

```
#!/bin/sh

if [ -r /etc/defaults/periodic.conf ]
then
	. /etc/defaults/periodic.conf
	source_periodic_confs
fi

case "${backup_enable}" in
	[Yy][Ee][Ss])
		;;
	*)
		return 0
		;;
esac

/path/to/backup/script/run_backup.sh
```

This script can then be enabled with ```backup_enable="YES"```
in ```/etc/periodic.conf```
