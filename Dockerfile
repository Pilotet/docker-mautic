FROM php:8.1-apache

# Instalar dependencias
RUN apt-get update && apt-get install -y \
    libicu-dev libpng-dev libjpeg-dev libfreetype6-dev \
    libxml2-dev libzip-dev unzip git curl \
    libonig-dev libpq-dev \
    && docker-php-ext-install intl pdo pdo_pgsql zip gd xml mbstring opcache \
    && a2enmod rewrite

# Instalar Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Clonar Mautic y preparar
WORKDIR /var/www/html
RUN git clone --branch 5.0.3 --depth=1 https://github.com/mautic/mautic.git . \
    && composer install --no-dev --no-interaction --optimize-autoloader \
    && chown -R www-data:www-data /var/www/html

EXPOSE 10000
CMD ["apache2-foreground"]
