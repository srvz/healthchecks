#!/bin/sh

# change dir to script dir
cd "$(dirname "$0")"
# backup name
NAME=healthchecks-data
# indicate which container should be backuped
CONTAINER=healthchecks
BACKUP_DIR="`pwd`/backup"
BACKUP_FILE="${NAME}-$(TZ=Asia/Shanghai date '+%Y%-m-%d_%H%M%S').json"

mkdir -p $BACKUP_DIR

docker exec $CONTAINER python manage.py dumpdata 1>${BACKUP_DIR}/${BACKUP_FILE} 2>/dev/null