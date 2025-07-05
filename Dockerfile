FROM php:8.1-apache

# Instala librerías de sistema + extensiones PHP
RUN apt-get update && apt-get install -y \
    libicu-dev libpng-dev libjpeg-dev libfreetype6-dev \
    libxml2-dev libzip-dev unzip git curl \
    libonig-dev libpq-dev libc-client-dev libkrb5-dev \
    libssl-dev libevent-dev libz-dev gnupg \
    && docker-php-ext-install intl pdo pdo_pgsql zip gd xml mbstring opcache sockets bcmath \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install imap

# Redis
RUN pecl install redis && docker-php-ext-enable redis

# Apache
RUN a2enmod rewrite

# Composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

# Node.js + npm
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# Instala Mautic 5
WORKDIR /var/www/html
RUN git clone --branch 5.0.3 --depth=1 https://github.com/mautic/mautic.git . \
    && composer install --no-dev --no-interaction --optimize-autoloader \
    && chown -R www-data:www-data /var/www/html

EXPOSE 10000
CMD ["apache2-foreground"]
