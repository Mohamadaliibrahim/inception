#!/bin/sh
 
# Generate SSL certificate and key
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/C=LB/ST=Beirut/L=Beirut/O=42Beirut/OU=Student/CN=mohamibr.42.fr"
 
# Run Nginx in the foreground
nginx -g 'daemon off;'