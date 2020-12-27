#!/bin/bash

while true; do
  DATE=$(TZ=Asia/Shanghai date "+%Y-%-m-%d %H:%M:%S")
  echo "[${DATE}] Start prune.sh"
  python manage.py pruneflips
  python manage.py prunenotifications
  python manage.py prunepings
  python manage.py prunetokenbucket
  DATE=$(TZ=Asia/Shanghai date "+%Y-%-m-%d %H:%M:%S")
  echo "[${DATE}] Stop prune.sh"
  sleep 600
done