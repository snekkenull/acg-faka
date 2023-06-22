FROM composer:latest AS composer

# ============================================== #

FROM php:8-apache

COPY --from=composer /usr/bin/composer /usr/bin/composer
COPY ./acg-faka/composer.json /var/www/html/composer.json
COPY ./acg-faka/composer.lock /var/www/html/composer.lock

RUN set -ex \
# install dependencies
    && apt-get update \
    && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libzip-dev \
# install php extensions
    && docker-php-ext-install \
        bcmath \
        gd \
        opcache \
        pcntl \
        pdo_mysql \
        zip \
    && pecl install \
        redis \
    && docker-php-ext-enable \
        redis \
# install composer dependencies
    && composer install -d /var/www/html \
# enable apache modules
    && a2enmod rewrite \
# php session store using redis
    && echo "session.save_handler = redis" >> /usr/local/etc/php/conf.d/docker-php-ext-redis.ini \
    && echo "session.save_path = tcp://redis:6379" >> /usr/local/etc/php/conf.d/docker-php-ext-redis.ini \
# set permissions
    && chown -R www-data:www-data /var/www/html \
# clean up
    && apt-get clean \
    && rm -rf /tmp/*

VOLUME /var/www/html