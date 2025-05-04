FROM alpine:3.18

RUN apk update && \
    apk add mariadb mariadb-client && \
    rm -rf /var/cache/apk/*

COPY ./conf/mariadb.conf /etc/my.cnf.d/mariadb-server.cnf
COPY ./tools/script.sh /

RUN chmod +x /script.sh

EXPOSE 3306

CMD [ "/script.sh" ]