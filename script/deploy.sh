#!/bin/sh

NETWORK=healthchecks
# 数据库端口，为避免冲突可改为其他端口
MYSQL_PORT=3306
MYSQL_ROOT_PASSWORD=MYSQL_ROOT_PASSW!ORD
MYSQL_DATABASE=healthchecks
MYSQL_USER=healthchecks
MYSQL_PASSWORD="health#checks"
MYSQL_VOLUME=healthchecks-db
DEBUG=False
# 必须与 EMAIL_HOST_USER 一致
DEFAULT_FROM_EMAIL="hc@example.com"
# 配置腾讯邮箱端口必须用 587 才能发送成功
EMAIL_HOST="smtp.exmail.qq.com"
EMAIL_PORT="587"
EMAIL_HOST_USER="hc@example.com"
EMAIL_HOST_PASSWORD="xxxxxxxx"
EMAIL_USE_TLS=True
# Healthchecks 服务端口，为避免冲突可改为其他端口
PORT=8088
HOST=`ifconfig eth0 2>/dev/null | awk '$1 == "inet" {print $2}'`
SITE_ROOT="http://${HOST:-localhost}:${PORT}"
SITE_NAME="Healthchecks"

OUT=`docker network inspect -f "{{.Name}}" $NETWORK 2>/dev/null`
if [ "$OUT" != "healthchecks" ]; then
  docker network create --attachable=true $NETWORK
fi

OUT=`docker volume inspect -f "{{.Name}}" $MYSQL_VOLUME 2>/dev/null`
if [ "$OUT" != "$MYSQL_VOLUME" ]; then
  docker volume create $MYSQL_VOLUME
fi

OUT=`docker container inspect -f "{{.State.Status}}" healthchecks-db 2>/dev/null`
if [ "$OUT" = "exited" ]; then
  docker start healthchecks-db
  sleep 5
fi

if [ -z $OUT ]; then
  docker run -d \
    --name healthchecks-db \
    --expose 3306 \
    -v healthchecks-db:/var/lib/mysql \
    -p $MYSQL_PORT:3306 \
    -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
    -e MYSQL_DATABASE=$MYSQL_DATABASE \
    -e MYSQL_USER=$MYSQL_USER \
    -e MYSQL_PASSWORD=$MYSQL_PASSWORD \
    --network healthchecks \
    mysql:5.7 --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
  sleep 20
fi

OUT=`docker container inspect -f "{{.State.Status}}" healthchecks 2>/dev/null`

if [ -n $OUT ]; then
  docker rm -fv healthchecks &>/dev/null
fi

docker run -d --init \
  --name healthchecks \
  -p $PORT:8000 \
  -e DEBUG=$DEBUG \
  -e DB=mysql \
  -e DB_HOST=healthchecks-db \
  -e DB_NAME=$MYSQL_DATABASE \
  -e DB_USER=$MYSQL_USER \
  -e DB_PASSWORD=$MYSQL_PASSWORD \
  -e DEFAULT_FROM_EMAIL=$DEFAULT_FROM_EMAIL \
  -e EMAIL_HOST=$EMAIL_HOST \
  -e EMAIL_PORT=$EMAIL_PORT \
  -e EMAIL_HOST_USER=$EMAIL_HOST_USER \
  -e EMAIL_HOST_PASSWORD=$EMAIL_HOST_PASSWORD \
  -e EMAIL_USE_TLS=$EMAIL_USE_TLS \
  -e SITE_ROOT=$SITE_ROOT \
  -e SITE_NAME=$SITE_NAME \
  --network healthchecks \
  srvz/healthchecks:v1.18
