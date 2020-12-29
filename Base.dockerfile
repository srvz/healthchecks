FROM python:3-alpine

ENV WORK_DIR="/app" DATA_DIR="/data"

RUN mkdir -p ${WORK_DIR} ${DATA_DIR} \
  && sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
  && pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

WORKDIR ${WORK_DIR}
ADD requirements.txt ${WORK_DIR}

RUN apk --update add --no-cache --virtual .build-deps gcc python3-dev musl-dev libffi-dev mariadb-dev postgresql-dev tzdata \
  && apk add --update --no-cache mariadb-connector-c-dev \
  && pip install uwsgi mysqlclient \
  && pip install -r requirements.txt \
  && echo "Asia/Shanghai" > /etc/timezone \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

VOLUME ${DATA_DIR}
