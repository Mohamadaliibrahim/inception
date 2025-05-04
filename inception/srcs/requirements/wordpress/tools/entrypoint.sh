#!/bin/sh

# Wait for MariaDB
while ! mysqladmin ping -h mariadb -u root -p${MYSQL_ROOT_PASSWORD} --silent; do
  sleep 5
done

# Clean directory if not empty
if [ -f "/var/www/html/wp-config.php" ] || [ -d "/var/www/html/wp-content" ]; then
  echo "Cleaning existing WordPress files..."
  rm -rf /var/www/html/*
fi

# Download and install WordPress
if [ ! -f "/var/www/html/wp-config.php" ]; then
  wp core download --allow-root
  wp config create \
    --dbname=${MYSQL_DATABASE} \
    --dbuser=${MYSQL_USER} \
    --dbpass=${MYSQL_PASSWORD} \
    --dbhost=mariadb:3306 \
    --allow-root
  wp core install \
    --url=https://${DOMAIN_NAME} \
    --title="Inception" \
    --admin_user=${WP_ADMIN_USER} \
    --admin_password=${WP_ADMIN_PASSWORD} \
    --admin_email=${WP_ADMIN_EMAIL} \
    --allow-root
fi

php-fpm82 -F