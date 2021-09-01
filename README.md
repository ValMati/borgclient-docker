# BORG CLIENT

[![.github/workflows/docker-publish.yml](https://github.com/ValMati/borgclient-docker/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/ValMati/borgserver-docker/actions/workflows/docker-publish.yml)

Docker image with a SSH client and BorgBackup installed and ready to use as a backup client over SSH.

The idea of this image is to be used on computers that are not always on (laptops or desktop workstations), so the backup is scheduled for 5 minutes after the container starts.

## Source Code & Image

The code is available on [GitHub](https://github.com/ValMati/borgclient-docker)

With each release a new version of the image is published on [DockerHub](https://hub.docker.com/r/valmati/borgclient)

## Usage

It is recommended to launch the image from a docker-compose as in the [example](docker-compose.yml).

As usual, it is necessary to indicate the image, in this case [valmati/borgclient:latest](https://hub.docker.com/r/valmati/borgclient).

The following is a description of each of the fields to be given a value in the docker-compose.

### Hostname

It's important set the hostname because the host keys have information about this.

### Environment

The following are the environment variables to be defined:

| Variable | Description | Value |
| --- | --- | --- |
| TZ            | Time Zone | Europe/Madrid |
| BORG_SERVER   | IP or domain of the server on which the backups will be made | 192.168.1.200 |
| PREFIX        | Prefix with which the files in the backup will be created | ClientPrefix |
| BOT_TOKEN     | Token of the bot through which we will receive Telegram notifications. | 123:ABC |
| CHAT_ID       | Identifier of the user or group that will receive Telegram notifications.| -123 |
| PASSPHRASE    | Repository backup passphrase | passphrase |
| REPO_PATH     | Path of the repository inside the server. This path can be relative or absolute. It should be noted that on the server access may be restricted by *--restrict-to-path* | ./ |
| KEEP_HOURLY   | * | 4 |
| KEEP_DAILY    | * | 7 |
| KEEP_WEEKLY   | * | 4 |
| KEEP_MONTHLY  | * | 6 |

\* see [BorgBackup documentation](https://borgbackup.readthedocs.io/en/stable/usage/prune.html) about prune and de KEEP_* flags

### Volumes

The *borgclient* container must have access to three volumes:

#### SSH Keys (/root/.ssh/)

In this volume there are two things:

* The customer SSH keys, if they do not exist they will be created.

* A *known_hosts* file with the server key. If they do not exist we can try to start from the container a connection with the server and then we will be asked to accept the key, in which case the file will be created.

#### Log (/log/)

The volume where the container generates the logs.

#### Borg Config (/borgconfig/)

In this volume the container look for a file *exclude.txt*, a file with exclude patterns from EXCLUDEFILE, one per line.

#### Backup (/backup/)

This volume is the source to backup.

## Inspired on

https://github.com/MrCaringi/Backups-and-Replication/
