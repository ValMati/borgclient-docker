#/bin/sh

# Constants
BORG_USER='borguser'
CURRENT_ARCHIVE=${PREFIX}'-'$(date +"%Y-%m-%d_%H:%M:%S")
LOG_FILE='/log/'${CURRENT_ARCHIVE}'.log'

# Export BorgBackup variables
export BORG_REPO='ssh://'${BORG_USER}'@'${BORG_SERVER}'/./'
export BORG_PASSPHRASE=${PASSPHRASE}

# Some helpers
info() { printf "%s: %s\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$*"; }

append_log() { echo -e "\n\n### ${*} ###\n" >> ${LOG_FILE}; }

send_telegram_message() {
    curl -s \
        --data parse_mode=HTML \
        --data chat_id=${CHAT_ID} \
        --data text="<b>BorgBackup</b>%0A      <i>from <b>#`hostname`</b></i>%0A%0A${*}" \
        "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
        > /dev/null 2>&1
}

send_telegram_file() {
    BODY=${1}
    FILE=${2}
    HOSTNAME=`hostname`

    curl -v -4 -F \
        "chat_id=${CHAT_ID}" \
        -F document=@${FILE} \
        -F caption="BorgBackup"$'\n'"        from: #${HOSTNAME}"$'\n\n'"${BODY}" \
        https://api.telegram.org/bot${BOT_TOKEN}/sendDocument \
        > /dev/null 2>&1
}

# Error handling
trap 'echo $(date +"%Y-%m-%d %H:%M:%S"): Backup interrupted ; exit 2' INT TERM

# Create log file
touch ${LOG_FILE}

# Create
message="Starting borg create (${CURRENT_ARCHIVE})"
info ${message}
send_telegram_message ${message}
append_log "${message}"
borg create --stats --list --filter=E --files-cache ctime,size --exclude-from /borgconfig/exclude.txt --compression auto,lzma,9 ::${CURRENT_ARCHIVE} /backup/* >> ${LOG_FILE} 2>&1

create_exit=$?
info "Create finished with code: ${create_exit}"

# Prune
if [ ${create_exit} -eq 0 ]; then
    message="Starting prune (${CURRENT_ARCHIVE})"
    info ${message}
    send_telegram_message ${message}
    append_log "${message}"
    borg prune -v -s --list --prefix ${PREFIX}- --keep-hourly=${KEEP_HOURLY} --keep-daily=${KEEP_DAILY} --keep-weekly=${KEEP_WEEKLY} --keep-monthly=${KEEP_MONTHLY} $REP >> ${LOG_FILE} 2>&1

    prune_exit=$?
    info "Prune finished with code: ${prune_exit}"
fi

# Use highest exit code as global exit code
global_exit=$(( create_exit > prune_exit ? create_exit : prune_exit ))

if [ ${global_exit} -eq 0 ]; then
    message="Backup and Prune finished #OK (${CURRENT_ARCHIVE})"
elif [ ${global_exit} -eq 1 ]; then
    message="Backup and/or Prune finished with #WARNINGS (${CURRENT_ARCHIVE})"
else
    message="Backup and/or Prune finished with #ERRORS (${CURRENT_ARCHIVE})"
fi
info ${message}
append_log "${message}"
send_telegram_file "${message}" "${LOG_FILE}"

exit ${global_exit}