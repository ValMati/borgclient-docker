FROM alpine:3.15.0

RUN apk add --update openssh-client borgbackup tzdata curl py3-pip && \
    rm -rf /tmp/* /var/cache/apk/*

COPY entrypoint.sh borg_backup.sh borg_init.sh /bin/

ENTRYPOINT [ "/bin/entrypoint.sh" ]

CMD [ "crond", "-f", "-l", "2" ]
