#!/bin/bash

: ${WWW_UID:=33}
: ${WWW_GID:=33}

usermod -u $WWW_UID www-data
groupmod -g $WWW_GID www-data

sudo -u www-data php /var/www/html/artisan config:cache
sudo -u www-data php /var/www/html/artisan event:cache
sudo -u www-data php /var/www/html/artisan route:cache
sudo -u www-data php /var/www/html/artisan view:cache
sudo -u www-data php /var/www/html/artisan optimize
sudo -u www-data php /var/www/html/artisan migrate --no-interaction --force

# Start supervisord and services
exec /usr/bin/supervisord  -n -c /etc/supervisor/supervisord.conf
