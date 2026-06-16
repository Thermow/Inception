FROM debian:bookworm

RUN apt-get update && apt-get install -y mariadb-server && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY ./50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
RUN chmod 644 /etc/mysql/mariadb.conf.d/50-server.cnf

RUN mkdir -p /run/mysqld \
    && chown -R mysql:mysql /run/mysqld \
    && rm -rf /var/lib/mysql/* \
    && chown mysql:mysql /var/lib/mysql

EXPOSE 3306

CMD ["sh", "/entrypoint.sh"]
