# Usa PHP con Apache
FROM php:8.1-apache

# Instala dependencias del sistema y extensiones necesarias
RUN apt-get update && apt-get install -y \
    libicu-dev libpng-dev libjpeg-dev libfreetype6-dev \
    libxml2-dev libzip-dev unzip git curl \
    libonig-dev libpq-dev libc-client-dev libkrb5-dev \
    libssl-dev libevent-dev libz-dev gnupg \
    zlib1g-dev libwebp-dev libxpm-dev libvpx-dev \
    nodejs npm \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install \
        intl pdo pdo_pgsql pdo_mysql zip gd xml mbstring opcache sockets bcmath \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install imap

# Habilita módulos de Apache necesarios
RUN a2enmod rewrite headers

# Clona el código fuente de Mautic
WORKDIR /var/www/html
RUN git clone --branch 5.0.3 --depth=1 https://github.com/mautic/mautic.git . \
    && composer install --no-dev --no-interaction --optimize-autoloader

# Construye los assets de Mautic
RUN npm ci --prefer-offline --no-audit \
    && npx patch-package \
    && npm run build

# Genera los assets finales
RUN bin/console mautic:assets:generate || true

# Corrige permisos
RUN chown -R www-data:www-data /var/www/html

# Expón el puerto (Render detectará esto)
EXPOSE 80
