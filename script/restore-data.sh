#!/bin/sh

cd "$(dirname "$0")"
CONTAINER=healthchecks
BACKUP_DIR="`pwd`/backup"
BACKUP_FILE="指定备份文件的名字"

docker cp ${BACKUP_DIR}/${BACKUP_FILE} $CONTAINER:/app/dumpdata.json
docker exec $CONTAINER python manage.py loaddata dumpdata.json