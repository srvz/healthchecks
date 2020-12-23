FROM python:3-alpine
ADD . /app
WORKDIR /app
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
  && apk update && apk add postgresql-dev gcc python3-dev musl-dev libffi-dev
RUN pip install uwsgi -i https://pypi.tuna.tsinghua.edu.cn/simple \
  && pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
EXPOSE 8000
CMD ["uwsgi", "config.ini"]