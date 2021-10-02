#!/bin/sh
set -e

envsubst "$(printf '${%s} ' $(env | sed -e 's/=.*//'))" < /etc/nginx/templates/default.template > /etc/nginx/conf.d/default.conf
envsubst "$(printf '${%s} ' $(env | sed -e 's/=.*//'))" < /etc/php7/php-fpm.d/www.template > /etc/php7/php-fpm.d/www.conf

exec "$@"