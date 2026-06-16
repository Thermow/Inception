FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    mariadb-client \
    netcat-openbsd \
    php-fpm \
    php-mysql \
    curl \
    unzip\
    && rm -rf /var/lib/apt/lists/*

# WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

COPY ./entrypoint.sh /entrypoint.sh
COPY www.conf /etc/php/8.2/fpm/pool.d/www.conf
RUN chmod +x /entrypoint.sh

WORKDIR /var/www/html

CMD ["/entrypoint.sh"]