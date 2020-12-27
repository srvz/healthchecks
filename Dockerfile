FROM srvz/healthchecks:base

ADD . .
EXPOSE 8000

CMD ["uwsgi", "config.ini"]