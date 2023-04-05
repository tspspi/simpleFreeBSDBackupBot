#!/bin/sh

if [ $# -lt 1 ]; then
	echo "Missing execution job type (quaddaily, daily, weekly, monthly)"
	return 1
fi

if [ -r /etc/rsyncup.conf ]; then
	. /etc/rsyncup.conf
fi

if [ -z "${rsyncup_logfile}" ]; then
	LOGFILEC="/var/log/rsyncup.log"
else
	LOGFILEC=${rsyncup_logfile}
fi

if [ -z "${rsyncup_debuglogfile}" ]; then
	LOGFILE="/var/log/rsyncup_debug.log"
else
	LOGFILE=${rsyncup_debuglogfile}
fi

if [ -z "${rsyncup_keyfile}" ]; then
	KEYFILE="/root/.ssh/id_backup"
else
	KEYFILE="${rsyncup_keyfile}"
fi

case "$rsyncup_enable" in
	[Yy][Ee][Ss])
		;;
	*)
		return 0
		;;
esac

# Load list of datasets ...
dslist="${rsyncup_jobs}"
if [ -z "$dslist" ]; then
	echo "rsyncup: No datasets have been specified via rsyncup_jobs"
	return 1
fi

for job in ${dslist}; do
	# Split into source path, destination path and runtype
	SRC=`echo ${job} | awk '{split($0,a,";"); print a[1]}'`
	DST=`echo ${job} | awk '{split($0,a,";"); print a[2]}'`
	RUNTYPE=`echo ${job} | awk '{split($0,a,";"); print a[3]}'`
	RSPATH=`echo ${job} | awk '{split($0,a,";"); print a[4]}'`

	echo "Next backup job ..."
	echo "   Source: ${SRC}"
	echo "   Destination: ${DST}"
	echo "   Runtype: ${RUNTYPE}"
	echo "   Rsync path: ${RSPATH}"

	if [ ${RUNTYPE} == ${1} ]; then
		echo "   Executing"

		if [ ! -z ${RSPATH} ]; then
			RP="--rsync-path \"${RSPATH}\""
		else
			RP=""
		fi

		TSSTART=`date`

		echo "[${TSSTART}] Starting backup ${SRC}" >> ${LOGFILEC}

		# echo "rsync -av -e \"ssh -i /root/.ssh/id_backup\" ${SRC} ${DST} >> ${LOGFILE}"
		rsync --exclude ".cache" --exclude ".ssh" -av -e "ssh -i ${KEYFILE}" ${ARGS} ${RP} ${SRC} ${DST} >> ${LOGFILE}
		RC=$?

		TSEND=`date`

		if [ ${RC} -ne 0 ]; then
			if [ ${RC} -ne 23 ]; then
				# Failed
				echo "[${TSEND}] Failed to backup ${SRC} (code $RC)" >> ${LOGFILEC}
			else
				echo "[${TSEND}] Done ${SRC} (some files missing: Permissions)" >> ${LOGFILEC}
			fi
		else
			echo "[${TSEND}] Done ${SRC}" >> ${LOGFILEC}
		fi
	else
		echo "   Not executing (wrong jobtype)"
	fi
done
