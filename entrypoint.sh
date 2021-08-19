#!/bin/sh

BACKUP_DELAY=5
CRONTAB_FILE='/etc/crontabs/root'

current_minute=$(date +"%M")
current_hour=$(date +"%H")

future_hour=$(( (${current_hour} + (${current_minute} + ${BACKUP_DELAY}) / 60) % 24 ))
future_minute=$(( (${current_minute} + ${BACKUP_DELAY}) % 60 ))

echo 'Adding task to crontab...'
echo -e ${future_minute}'\t'${future_hour}'\t*\t*\t*\t/bin/backup_script.sh' 2>&1 | tee -a ${CRONTAB_FILE}

exec "$@"