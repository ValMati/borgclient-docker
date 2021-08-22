#!/bin/sh

HOST_KEYS_DIR='/root/.ssh'
EXCLUDE_FILE='/borgconfig/exclude.txt'
BACKUP_DELAY=5
CRONTAB_FILE='/etc/crontabs/root'

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

echo -e ${future_minute}'\t'${future_hour}'\t*\t*\t*\t/bin/borg.sh' 2>&1 | tee -a ${CRONTAB_FILE}

exec "$@"
