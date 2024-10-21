FROM python:3.8.15-slim-buster

WORKDIR /src

COPY . /src
COPY ./docker/entrypoint.sh /entrypoint.sh
COPY ./docker/server.ini /docker_server.ini
# deploy scripts

# Добавление пакета psycopg2 для работы с PostgreSQL
RUN apt-get update && apt-get install -y --no-install-recommends  build-essential libgdk-pixbuf2.0-0 \
    libpq-dev libsasl2-dev libldap2-dev libssl-dev libmagic1 redis-tools netcat \
    && pip install -U pip --no-cache-dir \
    && pip install psycopg2 \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ \
    && pip install . --no-cache-dir \
    && chmod +x /entrypoint.sh \
    && rm -rf /src

WORKDIR /home/faraday

RUN mkdir -p /home/faraday/.faraday/config
RUN mkdir -p /home/faraday/.faraday/logs
RUN mkdir -p /home/faraday/.faraday/session
RUN mkdir -p /home/faraday/.faraday/storage

# Выполнение миграций для инициализации базы данных
RUN faraday-manage initdb

ENV PYTHONUNBUFFERED 1
ENV FARADAY_HOME /home/faraday
