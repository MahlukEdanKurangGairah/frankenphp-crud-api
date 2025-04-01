# Gunakan image base PHP dengan OpenSwoole
FROM dunglas/frankenphp:builder-php8.3.16
# Install dependensi yang diperlukan
RUN apt-get update && apt-get install --no-install-recommends --no-install-suggests -y curl unzip nano \
    && apt autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install pdo_mysql mysqli pcntl opcache
RUN docker-php-ext-configure intl --enable-intl \
	&& docker-php-ext-configure pcntl --enable-pcntl \
	&& docker-php-ext-configure opcache --enable-opcache

ENV TZ="Asia/Jakarta"
ENV MYSQL_HOST=172.17.0.1
ENV MYSQL_PORT=3307
ENV MYSQL_USER=admin
ENV MYSQL_PASSWORD=qwerty234*
ENV MYSQL_DATABASE=mylog2
ENV COMPOSER_ALLOW_SUPERUSER=1
#ENV GID=1000
#ENV UID=1000
ENV WEB_SERVER_PORT=80
ENV WEB_SERVER_SSL_PORT=443
ENV ADMIN_PORT=2019
ENV PHP_INI_DIR=/usr/local/etc/php
ENV FRANKENPHP_WORKERS_MIN=2
ENV FRANKENPHP_WORKERS_MAX=10
ENV FRANKENPHP_WORKER_TIMEOUT=60s

#RUN groupadd -g ${GID} -o adjadtea
#RUN useradd -m -u ${UID} -g ${GID} -o -s /bin/bash adjadtea

# copy php.ini
#RUN cp ${PHP_INI_DIR}/php.ini-development ${PHP_INI_DIR}/php.ini
COPY ./php.ini ${PHP_INI_DIR}/php.ini
COPY ./Caddyfile /etc/caddy/Caddyfile
COPY ./index.php /var/www/html/index.php
COPY ./composer.json /var/www/html/composer.json


# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN set -eux; cd /var/www/html; composer install --no-dev --optimize-autoloader; \
	composer require mevdschee/php-crud-api

# Set working directory
WORKDIR /var/www/html
#RUN chown -R ${UID}:${GID} /var/www/html

EXPOSE ${WEB_SERVER_PORT}
EXPOSE ${WEB_SERVER_SSL_PORT}
EXPOSE ${ADMIN_PORT}
