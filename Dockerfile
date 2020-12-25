ARG DOCKER_TAG
FROM php:${DOCKER_TAG}

RUN DISTRO="$(cat /etc/os-release | grep -E ^ID= | cut -d = -f 2)"; \
  if [ "${DISTRO}" = "ubuntu" ]; then \
    DEBIAN_FRONTEND=noninteractive apt-get update -q -y; \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -q -y; \
    DEBIAN_FRONTEND=noninteractive apt-get install -qq -y curl git zip unzip; \
  fi; \
  if [ "${DISTRO}" = "alpine" ]; then \
    apk update; apk upgrade; apk add curl git zip unzip bash; rm /var/cache/apk/*; \
  fi

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/bin/

RUN ext="bcmath bz2 calendar exif intl gd ldap memcached OPcache pdo_mysql pdo_pgsql pgsql redis soap xsl zip sockets imagick"; \
  v="${DOCKER_TAG}\n7.2"; if [[ "`printf ${v}`" != "`printf ${v} | sort -V`" ]]; then ext="$ext mcrypt";fi; \
  v="${DOCKER_TAG}\n7"; if [[ "`printf ${v}`" != "`printf ${v} | sort -V`" ]]; then ext="$ext mysqli";fi; \
  install-php-extensions "$ext"

ENV PATH=$PATH:/root/composer/vendor/bin COMPOSER_ALLOW_SUPERUSER=1
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && ln -s $(composer config --global home) /root/composer
