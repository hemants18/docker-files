# Use PHP 8.2 FPM on Alpine Linux for a lightweight image
FROM php:8.2-fpm-alpine

# Install PDO MySQL driver
RUN docker-php-ext-install pdo pdo_mysql

# Install necessary system dependencies
RUN apk update && apk add --no-cache \
    bash \
    curl \
    zip \
    unzip \
    libzip-dev \
    zlib-dev \
    oniguruma-dev \
    postgresql-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    git \
    build-base \
    autoconf

# Configure and install PHP extensions
RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-install zip gd mbstring pdo pdo_pgsql opcache

# Install Composer globally
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html/

# Copy only composer files first to optimize caching
COPY composer.json ./

# Copy Laravel project files with ownership
COPY --chown=www-data:www-data . .

# Set file permissions
RUN chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Expose PHP-FPM port
EXPOSE 9000

# Run commands before starting PHP-FPM
CMD ["php-fpm"]
