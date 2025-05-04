FROM alpine:3.18

RUN apk update && \
    apk add php82 php82-fpm php82-mysqli php82-json php82-mbstring php82-gd php82-curl php82-opcache php82-xml php82-phar wget mariadb-client && \
    sed -i "s|listen = 127.0.0.1:9000|listen = 0.0.0.0:9000|g" /etc/php82/php-fpm.d/www.conf && \
    sed -i "s|memory_limit = 128M|memory_limit = 512M|g" /etc/php82/php.ini && \
    wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp && \
    ln -s /usr/bin/php82 /usr/bin/php && \
    rm -rf /var/cache/apk/*

COPY ./tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["/entrypoint.sh"]