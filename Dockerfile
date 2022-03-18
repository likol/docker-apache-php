FROM php:5.6-apache

RUN apt-get update && apt-get install -y \
    git \
    zlib1g-dev \
    unixodbc \
    unixodbc-dev \
    freetds-dev \
    freetds-bin \
    tdsodbc \
    libpng-dev \
    libjpeg-dev \
    libicu-dev &&\
    rm -rf /var/lib/apt/lists/*;

RUN set -x \
    && cd /usr/src/ && tar -xf php.tar.xz && mv php-5* php \
    && cd /usr/src/php/ext/odbc \
    && phpize \
    && sed -ri 's@^ *test +"\$PHP_.*" *= *"no" *&& *PHP_.*=yes *$@#&@g' configure \
    && ./configure --with-unixODBC=shared,/usr > /dev/null \
    && docker-php-ext-install odbc > /dev/null

# Type docker-php-ext-install to see available extensions
RUN docker-php-ext-configure pdo_dblib --with-libdir=/lib/x86_64-linux-gnu

# install xdebug
# RUN pecl install xdebug
RUN docker-php-ext-install pdo intl mbstring mysql gd pdo_dblib
RUN docker-php-ext-enable intl mbstring pdo_dblib mysql
# RUN echo "error_reporting = E_ALL" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini &&\
#     echo "display_startup_errors = On" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini &&\
#     echo "display_errors = On" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini &&\
    # echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini &&\
    # echo "xdebug.remote_connect_back=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini &&\
    # echo "xdebug.idekey=\"PHPSTORM\"" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini &&\
    # echo "xdebug.remote_port=9001" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

RUN pecl channel-update pecl.php.net \
    && pecl install xdebug-2.5.5 \
    && docker-php-ext-enable xdebug

RUN ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/