#!/bin/sh

HOST_KEYS_DIR='/root/.ssh'
EXCLUDE_FILE='/borgconfig/exclude.txt'
BACKUP_DELAY=5
CRONTAB_FILE='/etc/crontabs/root'
BORG_SCRIPT='/bin/borg.sh'

echo "> Configuring borg client"

# Generate host keys if is necesary
echo ">> Generating host keys if is necesary"
if [ ! -f "${HOST_KEYS_DIR}/id_rsa" ]; then
    ssh-keygen -f ${HOST_KEYS_DIR}/id_rsa -N '' -t rsa
fi

# Check exclude file
echo ">> Checking if exclude file exists"
if [ ! -f ${EXCLUDE_FILE} ]; then
	echo "Exclude file does not exists, creating..."
    touch ${EXCLUDE_FILE}
fi

# Add bakup task to crontab
echo '>> Adding backup task to crontab...'

current_hour=$(date +"%H")
current_minute=$(date +"%M")

current_hour=${current_hour#"${current_hour%%[!0]*}"}
current_minute=${current_minute#"${current_minute%%[!0]*}"}

future_hour=$(( (${current_hour} + ((${current_minute} + ${BACKUP_DELAY}) / 60)) % 24 ))
future_minute=$(( (${current_minute} + ${BACKUP_DELAY}) % 60 ))

borg_task=${future_minute}'\t'${future_hour}'\t*\t*\t*\t'${BORG_SCRIPT}
grep=$(grep "${BORG_SCRIPT}" ${CRONTAB_FILE})
if [ "${grep}" = "" ]; then
	echo "Adding..."
    echo -e "${borg_task}" 2>&1 | tee -a ${CRONTAB_FILE}
else
    echo "Updating..."
    echo -e "${borg_task}"
    sed -i '/borg.sh/c'${borg_task} ${CRONTAB_FILE}
fi

exec "$@"
