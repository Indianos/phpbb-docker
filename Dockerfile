# phpBB Dockerfile

FROM php:8-apache

COPY --from=composer /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1

# Do a dist-upgrade and install the required packages:
RUN export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get dist-upgrade -y \
  && apt-get install --no-install-recommends --no-install-suggests -y \
    libpng-dev \
    libjpeg-dev \
    imagemagick \
    jq \
    bzip2 \
    zip unzip \
    p7zip p7zip-full

# Install required PHP extensions:
RUN docker-php-ext-configure \
    gd --with-jpeg \
  && docker-php-ext-install \
    gd \
    mysqli \
    zip

# Uninstall obsolete packages:
RUN apt-get autoremove -y \
    libpng-dev \
    libjpeg-dev

# Remove obsolete files:
RUN apt-get clean \
  && rm -rf \
    /tmp/* \
    /usr/share/doc/* \
    /var/cache/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# Enable the Apache Rewrite module:
RUN ln -s /etc/apache2/mods-available/rewrite.load \
  /etc/apache2/mods-enabled/rewrite.load

# Enable the Apache Headers module:
RUN ln -s /etc/apache2/mods-available/headers.load \
  /etc/apache2/mods-enabled/headers.load

# Add a custom Apache config:
COPY apache.conf /etc/apache2/conf-enabled/custom.conf

# Add the PHP config file:
COPY php.ini /usr/local/etc/php/

# Add the custom Apache run script
# and a script to download and extract the latest stable phpBB version:
COPY bin /usr/local/bin

# Install phpBB into the Apache document root:
RUN download-phpbb /var/www/phpBB \
  && rm -rf \
    /var/www/phpBB/install \
    /var/www/phpBB/docs \
    /var/www/html \
  && mv /var/www/phpBB /var/www/html

# Add the phpBB config file:
COPY config.php /var/www/html/

# Expose the phpBB upload directories as volumes:
VOLUME \
  /var/www/html/files \
  /var/www/html/store \
  /var/www/html/images/avatars/upload

CMD ["phpbb-apache2"]
