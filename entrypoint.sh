#!/bin/sh

BACKUP_DELAY=1
CRONTAB_FILE='/etc/crontabs/root'

current_hour=$(date +"%H")
current_minute=$(date +"%M")

current_hour=${current_hour#"${current_hour%%[!0]*}"}
current_minute=${current_minute#"${current_minute%%[!0]*}"}

future_hour=$(( (${current_hour} + ((${current_minute} + ${BACKUP_DELAY}) / 60)) % 24 ))
future_minute=$(( (${current_minute} + ${BACKUP_DELAY}) % 60 ))

echo 'Adding backup task to crontab...'
echo -e ${future_minute}'\t'${future_hour}'\t*\t*\t*\t/bin/borg.sh' 2>&1 | tee -a ${CRONTAB_FILE}

exec "$@"
