FROM postgres:17

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y wget build-essential postgresql-server-dev-17

COPY ./init.sh /docker-entrypoint-initdb.d/init.sh
RUN chmod +x /docker-entrypoint-initdb.d/init.sh