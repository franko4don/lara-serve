# Alpine Image for Nginx and PHP

# NGINX x ALPINE.
FROM nginx:mainline-alpine

# MAINTAINER OF THE PACKAGE.
LABEL maintainer="Nwanze Franklin <franko4don@gmail.com>"

# INSTALL BASH AND SUPERVISOR
RUN apk --update --no-cache add ca-certificates \
    bash \
    supervisor

# trust this project public key to trust the packages.
ADD https://php.codecasts.rocks/php-alpine.rsa.pub /etc/apk/keys/php-alpine.rsa.pub

# IMAGE ARGUMENTS WITH DEFAULTS.
ARG PHP_VERSION=7.2
ARG ALPINE_VERSION=3.7
ARG COMPOSER_HASH=93b54496392c062774670ac18b134c3b3a95e5a5e5c8f1a9f115f203b75bf9a129d5daa8ba6a13e2cc8a1da0806388a8
ARG NGINX_HTTP_PORT=80
ARG NGINX_HTTPS_PORT=443

# CONFIGURE ALPINE REPOSITORIES AND PHP BUILD DIR.
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION}/main" > /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION}/community" >> /etc/apk/repositories && \
    echo "@php https://php.codecasts.rocks/v${ALPINE_VERSION}/php-${PHP_VERSION}" >> /etc/apk/repositories

# INSTALL PHP AND SOME EXTENSIONS. SEE: https://github.com/codecasts/php-alpine
RUN apk add --no-cache --update php-fpm@php \
    php@php \
    php-openssl@php \
    php-pdo@php \
    php-pdo_mysql@php \
    php-mbstring@php \
    php-phar@php \
    php-session@php \
    php-dom@php \
    php-ctype@php \
    php-zlib@php \
    php-json@php \
    php-xml@php && \
    ln -s /usr/bin/php7 /usr/bin/php

# CONFIGURE WEB SERVER.
RUN mkdir -p /var/www && \
    mkdir -p /run/php && \
    mkdir -p /run/nginx && \
    mkdir -p /var/log/supervisor && \
    mkdir -p /etc/nginx/sites-enabled && \
    mkdir -p /etc/nginx/sites-available

# INSTALL COMPOSER.
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('SHA384', 'composer-setup.php') === '${COMPOSER_HASH}') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php --install-dir=/usr/bin --filename=composer && \
    php -r "unlink('composer-setup.php');"


# EXPOSE PORTS!
EXPOSE ${NGINX_HTTPS_PORT} ${NGINX_HTTP_PORT}

# SET THE WORK DIRECTORY.
WORKDIR /var/www


# KICKSTART!
