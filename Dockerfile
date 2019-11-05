# Alpine Image for Nginx and PHP

# NGINX x ALPINE.
FROM nginx:mainline-alpine

# MAINTAINER OF THE PACKAGE.
LABEL maintainer="Nwanze Franklin <franko4don@gmail.com>"

# INSTALL BASH AND SUPERVISOR
RUN apk --update --no-cache add ca-certificates \
    bash \
    supervisor \
    nano \
    py-pip \
    certbot \
    curl

# trust this project public key to trust the packages.
ADD https://dl.bintray.com/php-alpine/key/php-alpine.rsa.pub /etc/apk/keys/php-alpine.rsa.pub

# IMAGE ARGUMENTS WITH DEFAULTS.
ARG PHP_VERSION=7.2
ARG ALPINE_VERSION=3.8
ARG COMPOSER_HASH=a5c698ffe4b8e849a443b120cd5ba38043260d5c4023dbf93e1558871f1f07f58274fc6f4c93bcfd858c6bd0775cd8d1


# CONFIGURE ALPINE REPOSITORIES AND PHP BUILD DIR.
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION}/main" > /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION}/community" >> /etc/apk/repositories && \
    echo "@php https://dl.bintray.com/php-alpine/v${ALPINE_VERSION}/php-${PHP_VERSION}" >> /etc/apk/repositories


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
    mkdir -p /etc/nginx/sites-available && \
    rm /etc/php7/php-fpm.d/www.conf && \
    rm /etc/nginx/nginx.conf && \
    rm /etc/supervisord.conf

# INSTALL COMPOSER.
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('SHA384', 'composer-setup.php') === '${COMPOSER_HASH}') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php --install-dir=/usr/bin --filename=composer && \
    php -r "unlink('composer-setup.php');"

# ADD CUSTOM CONFIGURATIONS
ADD fpm/www.conf /etc/php7/php-fpm.d/www.conf
ADD nginx/nginx.conf /etc/nginx/nginx.conf
ADD supervisor/supervisord.conf /etc/supervisord.conf
ADD nginx/default.conf /etc/nginx/sites-available/default.conf
ADD supervisor/conf.d/php-fpm-daemon.conf /etc/conf.d/php-fpm-daemon.conf
ADD supervisor/conf.d/nginx-daemon.conf /etc/conf.d/nginx-daemon.conf
ADD run.sh /run.sh
RUN chmod 755 /run.sh

# EXPOSE PORTS!
EXPOSE 80 443

# SET THE WORK DIRECTORY.
WORKDIR /var/www

# KICKSTART!
CMD ["/run.sh"]