FROM python:3-alpine

ENV DATA_DIR="/data" \
  WORK_DIR="/app" \
  UID="1000" \
  USER="healthchecks" \
  GID="1000" \
  GROUP="healthchecks"

RUN addgroup -g ${GID} ${GROUP} \
  && adduser -D -u ${UID} -G ${GROUP} -h /home/${USER} -s /bin/sh ${USER} \
  && mkdir -p ${WORK_DIR} ${DATA_DIR} \
  && chown ${USER}:${GROUP} -R ${WORK_DIR} ${DATA_DIR}

WORKDIR ${WORK_DIR}
ADD requirements.txt ${WORK_DIR}

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
  && apk --update add --no-cache --virtual .build-deps gcc python3-dev musl-dev libffi-dev mariadb-dev postgresql-dev tzdata \
  && apk add --update --no-cache mariadb-connector-c-dev \
  && pip install uwsgi mysqlclient -i https://pypi.tuna.tsinghua.edu.cn/simple \
  && pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple \
  && echo "Asia/Shanghai" > /etc/timezone \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

USER ${UID}
VOLUME ${DATA_DIR}
