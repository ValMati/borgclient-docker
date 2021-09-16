#!/bin/sh

HOST_KEYS_DIR='/root/.ssh'
EXCLUDE_FILE='/borgconfig/exclude.txt'
BACKUP_DELAY=5
CRONTAB_FILE='/etc/crontabs/root'
BORG_SCRIPT='/bin/borg_backup.sh'

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

# Changing scripts permissions
chmod a+x /bin/borg_backup.sh /bin/borg_init.sh

# Add bakup task to crontab
echo '>> Adding backup task to crontab...'

current_hour=$(date +"%H")
current_minute=$(date +"%M")

current_hour=${current_hour#"${current_hour%%[!0]*}"}
current_minute=${current_minute#"${current_minute%%[!0]*}"}

future_hour=$(( (${current_hour} + ((${current_minute} + ${BACKUP_DELAY}) / 60)) % 24 ))
future_minute=$(( (${current_minute} + ${BACKUP_DELAY}) % 60 ))

borg_task=${future_minute}'\t'

case ${FREQUENCY} in
    1)
        borg_task=${borg_task}'*'
        ;;
    2 | 3 | 4 | 6 | 8 | 12)
        if [ $(( ${future_hour} % ${FREQUENCY} )) -eq 0 ]; then
            borg_task=${borg_task}'*/'${FREQUENCY}
        else
            borg_task=${borg_task}${future_hour}
            cont=2
            max=$(( 24 / ${FREQUENCY} ))
            while [ ${cont} -le ${max} ]
            do
                future_hour=$(( (${future_hour} + 2) % 24 ))
                borg_task=${borg_task}','${future_hour}
                cont=$(( ${cont} + 1 ))
            done
        fi
        ;;
    *)
        borg_task=${borg_task}${future_hour}
        ;;
esac

borg_task=${borg_task}'\t*\t*\t*\t'${BORG_SCRIPT}

grep=$(grep "${BORG_SCRIPT}" ${CRONTAB_FILE})
if [ "${grep}" = "" ]; then
	echo "Adding..."
    echo -e "${borg_task}" 2>&1 | tee -a ${CRONTAB_FILE}
else
    echo "Updating..."
    echo -e "${borg_task}"
    sed -i '/borg_backup.sh/c'${borg_task} ${CRONTAB_FILE}
fi

exec "$@"
