FROM alpine:3.13

LABEL Maintainer="Eko Cahyo <ekocahyo27@gmail.com>"
LABEL Description="Lightweight container with Nginx latest version & PHP 7.4 based on Alpine Linux 3.13."

ARG timezone=Asia/Jakarta
ENV TIMEZONE=$timezone

# Set ENV PHP
ENV PHP_VERSION=7.4 \
    PHP_FPM_PM="dynamic" \
    PHP_FPM_MAX_CHILDREN="5" \
    PHP_FPM_START_SERVERS="2" \
    PHP_FPM_MIN_SPARE_SERVERS="1" \
    PHP_FPM_MAX_SPARE_SERVERS="2" \
    PHP_FPM_MAX_REQUESTS="1000" \
    PHP_FPM_PROCESS_IDLE_TIMEOUT="10s" \
    POST_MAX_SIZE="10M" \
    UPLOAD_MAX_FILESIZE="10M"

# Set ENV nginx
ENV CLIENT_MAX_BODY_SIZE=$POST_MAX_SIZE \
    ROOT_DIR="/usr/share/nginx/html"

# install depedency
RUN apk update; \
    apk add openssl curl ca-certificates gettext supervisor

# install nginx
RUN echo "http://nginx.org/packages/alpine/v"$(egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release)"/main" >> /etc/apk/repositories && cat /etc/apk/repositories; \
    curl -o /tmp/nginx_signing.rsa.pub https://nginx.org/keys/nginx_signing.rsa.pub; \
    openssl rsa -pubin -in /tmp/nginx_signing.rsa.pub -text -noout; \
    mv /tmp/nginx_signing.rsa.pub /etc/apk/keys/; \
    apk add --update-cache nginx

# install php
# ADD https://raw.githubusercontent.com/codecasts/php-alpine/master/php-alpine.rsa.pub /etc/apk/keys/php-alpine.rsa.pub
# RUN echo "https://dl.bintray.com/php-alpine/v"$(egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release)"/php-"$(echo $PHP_VERSION) >> /etc/apk/repositories

RUN apk add --update-cache php php-fpm php-mbstring php-json php-phar php-openssl; \
    set -x && adduser -u 1000 -D -S -G www-data www-data
    
RUN curl -o composer-setup.php https://getcomposer.org/installer && \
php -r "if (hash_file('sha384', 'composer-setup.php') === '906a84df04cea2aa72f40b5f787e49f22d4c2f19492ac310e8cba5b96ac8b64115ac402c8cd292b8a03482574915d1a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php --install-dir=/usr/bin --filename=composer && \
    php -r "unlink('composer-setup.php');"

COPY script /script

COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN chmod +x /script -R

RUN echo "<?php phpinfo();" > ${ROOT_DIR}/index.php
# Make sure files/folders in root dir vhost by the processes are accessable when they run under the www-data user
RUN chown -R www-data.www-data ${ROOT_DIR}

COPY config/php-pool.template /etc/php7/php-fpm.d/www.template

COPY config/nginx-default.template /etc/nginx/templates/default.template

COPY config/nginx.template /etc/nginx/nginx.conf

ENTRYPOINT ["/script/entrypoint.sh"]

WORKDIR ${ROOT_DIR}

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1/fpm-ping