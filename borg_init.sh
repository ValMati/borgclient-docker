#!/bin/sh

BORG_USER='borguser'

borg init --encryption=repokey ssh://${BORG_USER}@${BORG_SERVER}/${REPO_PATH}
