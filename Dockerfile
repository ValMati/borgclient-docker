FROM alpine:3.14.1

RUN apk add --update openssh-client borgbackup tzdata && \
    rm -rf /tmp/* /var/cache/apk/*

COPY entrypoint.sh backup_script.sh /bin/

ENTRYPOINT ["/bin/entrypoint.sh"]

CMD ["crond", "-f", "-l", "8"]