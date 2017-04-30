FROM php:7.1.3-fpm-alpine

MAINTAINER yakiniku <romsound040220@gmail.com>

# install libraries
RUN apk upgrade --update \
    && apk add \
       git \
       libmcrypt-dev \
       nginx \
       zlib-dev \
    && docker-php-ext-install \
        mcrypt \
        pdo_mysql \
        zip \
    && mkdir /run/nginx

# install compose
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
  && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
  && php -r "unlink('composer-setup.php');"

COPY lumen/composer.json /tmp/composer.json
COPY lumen/composer.lock /tmp/composer.lock

ENV COMPOSER_ALLOW_SUPERUSER 1

RUN composer install --no-scripts --no-autoloader -d /tmp

COPY lumen /var/www/lumen
WORKDIR /var/www/lumen

RUN mv -n /tmp/vendor ./ \
  && composer dump-autoload

RUN chown www-data:www-data storage/logs \
    && chown -R www-data:www-data storage/framework \
    && cp .env.example .env \
    && mkdir -p  /usr/share/nginx \
    && ln -s /var/www/laravel/public /usr/share/nginx/html

EXPOSE 80