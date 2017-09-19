FROM php:7.1-fpm-alpine

RUN apk update && apk upgrade && apk add --no-cache \
 libwebp-dev \
 curl-dev \
 curl \
 bash \
 libxml2-dev \
 readline \
 libtool \
 make \
 re2c \
 file \
 git \
 cyrus-sasl-dev \
 libmemcached-dev \
 zlib-dev \
 icu-dev \
 freetype \
 libpng \
 libjpeg-turbo \
 freetype-dev \
 libpng-dev \
 libjpeg-turbo-dev \
 autoconf \
 gcc \
 libmcrypt-dev \
 g++ \
 wget \
 ca-certificates \
 &&  update-ca-certificates

RUN docker-php-ext-configure gd \
    --with-gd \
    --with-freetype-dir=/usr/include/ \
    --with-png-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/ && \
  NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) && \
  docker-php-ext-configure intl && \
  docker-php-ext-install -j${NPROC} gd iconv mcrypt mbstring fileinfo curl ftp mysqli pdo_mysql intl opcache && \
  apk del --no-cache freetype-dev libpng-dev libjpeg-turbo-dev


RUN cd /tmp \
   && wget https://github.com/php-memcached-dev/php-memcached/archive/php7.zip \
   && unzip php7.zip \
   && cd php-memcached-php7 \
   && phpize \
   && ./configure --disable-memcached-sasl \
   && make \
   && make test \
   && make install \
   && echo "extension=memcached.so" > /usr/local/etc/php/conf.d/20_memcached.ini \
   && rm -rf /usr/share/php7 \
   && rm -rf /tmp/*


 # set recommended PHP.ini settings
 # see https://secure.php.net/manual/en/opcache.installation.php
 RUN { \
 		echo 'opcache.memory_consumption=128'; \
 		echo 'opcache.interned_strings_buffer=8'; \
 		echo 'opcache.max_accelerated_files=4000'; \
 		echo 'opcache.revalidate_freq=2'; \
 		echo 'opcache.fast_shutdown=1'; \
 		echo 'opcache.enable_cli=1'; \
 	} > /usr/local/etc/php/conf.d/opcache-recommended.ini


##
# Install composer
# source: https://getcomposer.org/download/
##
##
RUN curl -L https://getcomposer.org/installer -o composer-setup.php && \
    php composer-setup.php && \
    rm  composer-setup.php && \
    mv composer.phar /usr/local/bin/composer && \
    chmod +rx /usr/local/bin/composer && \
    # Remove cache and tmp files
    rm -rf /var/cache/apk/*


VOLUME ["/var/www/html"]
COPY nginx/conf.d/default.conf /nginx.conf
COPY entrypoint.sh /usr/local/bin/
RUN dos2unix /usr/local/bin/entrypoint.sh
WORKDIR /var/www/html

VOLUME ["/nginx/conf.d"]

ENTRYPOINT ["entrypoint.sh"]
CMD ["php-fpm"]
