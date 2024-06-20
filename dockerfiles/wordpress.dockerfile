FROM wordpress:6.5-php8.2-fpm-alpine

# Downloading install-php-extensions script and making it executable
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions

# Installing PHP extensions using install-php-extensions script
RUN install-php-extensions \
    mysqli \
    pdo \
    pdo_mysql \
    gd \
    zip \
    xml \
    curl \
    mbstring

# Cleaning APK cache
RUN rm -rf /var/cache/apk/*
