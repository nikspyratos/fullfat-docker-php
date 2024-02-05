ARG BASE_IMAGE=php:8.2-alpine
FROM ${BASE_IMAGE}

# Download script to install PHP extensions and dependencies
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions

RUN apk add --no-cache \
      coreutils \
      curl \
      git \
      zip unzip \
# iconv, mbstring and pdo_sqlite are omitted as they are already installed
    && PHP_EXTENSIONS=" \
      amqp \
      bcmath \
      bz2 \
      calendar \
      event \
      exif \
      gd \
      gettext \
      intl \
      ldap \
      memcached \
      mysqli \
      opcache \
      pcntl \
      pdo_mysql \
      pdo_pgsql \
      pgsql \
      redis \
      soap \
      sockets \
      xsl \
      zip \
    " \
    # Install Imagick from master on PHP >= 8.3, because imagick 3.7.0 broke on latest PHP releases and Imagick maintainers don't care to tag a newer release
    && if [ $(php -r 'echo PHP_VERSION_ID;') -lt 80300 ]; then \
      PHP_EXTENSIONS="$PHP_EXTENSIONS imagick"; \
      else PHP_EXTENSIONS="$PHP_EXTENSIONS https://api.github.com/repos/Imagick/imagick/tarball/28f27044e435a2b203e32675e942eb8de620ee58"; \
    fi \
    && install-php-extensions $PHP_EXTENSIONS \
    && if command -v a2enmod; then a2enmod rewrite; fi

# Install Composer.
ENV PATH=$PATH:/root/composer/vendor/bin \
  COMPOSER_ALLOW_SUPERUSER=1 \
  COMPOSER_HOME=/root/composer
RUN cd /root \
  # Download installer and check for its integrity.
  && curl -sSL https://getcomposer.org/installer > composer-setup.php \
  && curl -sSL https://composer.github.io/installer.sha384sum > composer-setup.sha384sum \
  && sha384sum --check composer-setup.sha384sum \
  # Install Composer 2.
  && php composer-setup.php --install-dir=/usr/local/bin --filename=composer --2 \
  # Remove installer files.
  && rm /root/composer-setup.php /root/composer-setup.sha384sum
