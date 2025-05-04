FROM alpine:3.18

RUN apk update && \
    apk add nginx openssl && \
    mkdir -p /etc/nginx/ssl && \
    rm -rf /var/cache/apk/*

RUN rm /etc/nginx/nginx.conf

COPY ./conf/nginx.conf /etc/nginx/nginx.conf
COPY ./tools/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]