FROM php:8.1-apache

RUN apt-get update && apt-get install -y \
    libicu-dev libpng-dev libjpeg-dev libfreetype6-dev \
    libxml2-dev libzip-dev unzip git curl \
    libonig-dev libpq-dev libc-client-dev libkrb5-dev \
    libssl-dev libevent-dev libz-dev \
    && docker-php-ext-install intl pdo pdo_pgsql zip gd xml mbstring opcache sockets bcmath \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install imap

RUN pecl install redis && docker-php-ext-enable redis

RUN a2enmod rewrite

RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

WORKDIR /var/www/html
RUN git clone --branch 5.0.3 --depth=1 https://github.com/mautic/mautic.git . \
    && composer install --no-dev --no-interaction --optimize-autoloader \
    && chown -R www-data:www-data /var/www/html

EXPOSE 10000
CMD ["apache2-foreground"]
