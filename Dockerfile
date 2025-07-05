FROM php:8.1-apache

# Instala dependencias del sistema
RUN apt-get update && apt-get install -y \
    libicu-dev libpng-dev libjpeg-dev libfreetype6-dev \
    libxml2-dev libzip-dev unzip git curl \
    libonig-dev libpq-dev \
    && docker-php-ext-install intl pdo pdo_pgsql zip gd xml mbstring opcache

# Habilita mod_rewrite
RUN a2enmod rewrite

# Descarga Mautic 5
WORKDIR /var/www/html
RUN curl -L https://github.com/mautic/mautic/releases/latest/download/mautic.zip -o mautic.zip \
    && unzip mautic.zip -d . \
    && rm mautic.zip

# Permisos
RUN chown -R www-data:www-data /var/www/html

EXPOSE 10000

CMD ["apache2-foreground"]
