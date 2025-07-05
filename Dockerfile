FROM php:8.1-apache

# Instala dependencias del sistema y extensiones PHP necesarias
RUN apt-get update && apt-get install -y \
    libicu-dev libpng-dev libjpeg-dev libfreetype6-dev \
    libxml2-dev libzip-dev unzip git curl \
    libonig-dev libpq-dev libc-client-dev libkrb5-dev \
    libssl-dev libevent-dev libz-dev \
    && docker-php-ext-install \
        intl pdo pdo_pgsql zip gd xml mbstring opcache sockets bcmath imap

# IMAP necesita flags especiales
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install imap

# Instala Redis desde PECL
RUN pecl install redis \
    && docker-php-ext-enable redis

# Activa mod_rewrite
RUN a2enmod rewrite

# Instala Composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

# Clona el código de Mautic 5 y prepara la app
WORKDIR /var/www/html
RUN git clone --branch 5.0.3 --depth=1 https://github.com/mautic/mautic.git . \
    && composer install --no-dev --no-interaction --optimize-autoloader \
    && chown -R www-data:www-data /var/www/html

EXPOSE 10000
CMD ["apache2-foreground"]

