#!/bin/sh

HOST_KEYS_DIR='/root/.ssh'
BACKUP_DELAY=5
CRONTAB_FILE='/etc/crontabs/root'

echo "> Configuring borg client"

# Generate host keys if is necesary
echo ">> Generating host keys if is necesary"
if [ ! -f "${HOST_KEYS_DIR}/id_rsa" ]; then
	ssh-keygen -f ${HOST_KEYS_DIR}/id_rsa -N '' -t rsa
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
