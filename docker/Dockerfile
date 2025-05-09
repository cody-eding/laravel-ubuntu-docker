ARG COMPOSER_VERSION=2
ARG UBUNTU_VERSION=noble
ARG NODE_VERSION=24
ARG PHP_VERSION=8.3

# Build PHP dependencies
FROM composer:$COMPOSER_VERSION as vendor
 
COPY . /app

WORKDIR /app
 
RUN composer install \
    --verbose \
    --prefer-dist \
    --no-progress \
    --no-interaction \
    #--no-dev \
    --optimize-autoloader

# Build frontend npm dependencies
FROM node:$NODE_VERSION as frontend

COPY . /app

WORKDIR /app
 
RUN npm install --verbose \
    && npm run build --verbose 

# Build production image
FROM ubuntu:$UBUNTU_VERSION
# Must be re-referenced after FROM
ARG UBUNTU_VERSION
ARG PHP_VERSION

# No tty
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    apache2 \
    nano \
    php$PHP_VERSION \
    php$PHP_VERSION-bcmath \
    php$PHP_VERSION-cli \
    php$PHP_VERSION-curl \
    php$PHP_VERSION-fpm \
    php$PHP_VERSION-gd \
    php$PHP_VERSION-igbinary \
    php$PHP_VERSION-imap \
    php$PHP_VERSION-intl \
    php$PHP_VERSION-ldap \
    php$PHP_VERSION-mbstring \
    php$PHP_VERSION-memcached \
    php$PHP_VERSION-msgpack \
    php$PHP_VERSION-pgsql \
    php$PHP_VERSION-readline \ 
    php$PHP_VERSION-redis \
    php$PHP_VERSION-soap \ 
    php$PHP_VERSION-sqlite3 \ 
    php$PHP_VERSION-xml \
    php$PHP_VERSION-zip \
    ssl-cert \
    sudo \
    supervisor \
    && a2dismod dav \
    && a2dismod dav_fs \
    && a2dismod dav_lock \
    && a2dismod info \
    && a2dismod mpm_prefork \
    && a2dismod userdir \
    && a2enmod headers \
    && a2enmod http2 \
    && a2enmod mpm_event \
    && a2enmod proxy \
    && a2enmod proxy_fcgi \
    && a2enmod remoteip \
    && a2enmod rewrite \
    && a2enmod reqtimeout \
    && a2enmod ssl \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create symlinks for php items for apache and supervisor to use
RUN ln -s "/usr/sbin/php-fpm$PHP_VERSION" /usr/sbin/php-fpm \
    && ln -s "/etc/php/$PHP_VERSION/" /etc/php/current \
    && ln -s "/run/php/php$PHP_VERSION-fpm.sock" /run/php/php-fpm.sock

# Configure supervisor
COPY ./docker/supervisord/supervisord.conf /etc/supervisor/supervisord.conf
COPY ./docker/supervisord/conf.d/ /etc/supervisor/conf.d/

# Configure apache
# Delete default website
RUN rm -f /etc/apache2/sites-enabled/000-default.conf
# actual apache configuration
COPY ./docker/apache/laravel.conf /etc/apache2/sites-enabled/laravel.conf

COPY . /var/www/html
COPY --from=vendor /app/vendor/ /var/www/html/vendor/
#COPY --from=frontend /app/public/js/ /var/www/html/public/js/
#COPY --from=frontend /app/public/css/ /var/www/html/public/css/
#COPY --from=frontend /app/mix-manifest.json /var/www/html/mix-manifest.json

# Change permissions of laravel applicaiton
# Change the ownership of the /var/www/html directory to the www-data user
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/ \
    && find /var/www/html -type f -exec chmod 644 {} \; \
    && chmod +x /var/www/html/artisan

# Startup script to change uid/gid (if environment variable passed) and start supervisord in foreground
COPY ./docker/scripts/start.sh /start.sh
RUN chmod 755 /start.sh

EXPOSE 443

CMD ["/bin/bash", "/start.sh"]
