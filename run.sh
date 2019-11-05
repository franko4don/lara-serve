#!/bin/bash

exec 
ln -s /etc/php7/php.ini /etc/php7/conf.d/php.ini
ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf
/usr/bin/supervisord -n -c /etc/supervisord.conf