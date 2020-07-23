FROM php:7.3-apache-stretch as base

ARG DEBIAN_FRONTEND=${DEBIAN_FRONTEND:-noninteractive}
ARG DEBCONF_NOWARNINGS=${DEBCONF_NOWARNINGS:-"yes"}
ARG VERSION_GLPI=${VERSION_GLPI:-9.4.5}

WORKDIR /var/www/html

RUN apt-get update \
    && apt-get -y install --no-install-recommends \
    mysql-client \
    curl \
    cron \
    wget \
    jq \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libxml2-dev \
    libc-client-dev \
    libkrb5-dev \
    libldap2-dev \
    && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# https://glpi-install.readthedocs.io/en/latest/prerequisites.html#mandatory-extensions
# https://glpi-install.readthedocs.io/en/latest/prerequisites.html#optional-extensions
RUN docker-php-ext-install mysqli \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install imap \
    && docker-php-ext-install ldap \
    && docker-php-ext-install xmlrpc \
    && docker-php-ext-install opcache \
    && docker-php-ext-install exif \
    && printf "\n" | pecl install apcu  \
    && a2enmod rewrite

COPY ["containers/php/conf.d/glpiconf.ini", "containers/php/conf.d/timezone.ini", "containers/php/conf.d/apcu.ini", "/usr/local/etc/php/conf.d/"]
COPY ["containers/glpi_cron", "/etc/cron.d/"]
COPY ["containers/apache2/000-default.conf", "/etc/apache2/sites-available/"]
COPY ["containers/ldap.conf", "/etc/ldap/"]
COPY ["containers/put_glpi.sh", "containers/entrypoint.sh", "/opt/"]

# Downloading plain glpi
RUN chmod +x /opt/put_glpi.sh \
    && chmod +x /opt/entrypoint.sh  \
    && /opt/put_glpi.sh \
    && rm /opt/put_glpi.sh \
    && apt-get purge --auto-remove -y jq

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["/opt/entrypoint.sh"]
CMD ["apache2-foreground"]

# -----------------------------
FROM base as production

ARG DEBIAN_FRONTEND=${DEBIAN_FRONTEND:-noninteractive}
ARG DEBCONF_NOWARNINGS=${DEBCONF_NOWARNINGS:-"yes"}
ARG TIMEZONE=${TIMEZONE:-Asia/Shanghai}
ARG TIME_ZONE=${TIMEZONE}
ARG LOCALEDEF_CHARMAP_FILE=${CHARMAP_FILE:-UTF-8}
ARG LOCALEDEF_INPUT_FILE=${LOCALEDEF_INPUT_FILE:-zh_CN}
ARG LOCALEDEF_OUTPUT_PATH=${LOCALEDEF_OUTPUT_PATH:-/usr/lib/locale/zh_CN.UTF-8}
ENV TZ=${TIMEZONE}

RUN apt-get update \
    && apt-get -y install --no-install-recommends \
    tzdata \
    locales \
    fonts-ipafont \
    && locale-gen \
    && localedef -f $LOCALEDEF_CHARMAP_FILE -i $LOCALEDEF_INPUT_FILE $LOCALEDEF_OUTPUT_PATH \
    && ln -snf /usr/share/zoneinfo/$TIME_ZONE /etc/localtime && echo $TIME_ZONE > /etc/timezone \
    && dpkg-reconfigure -f noninteractive tzdata \
    && dpkg-reconfigure -f noninteractive locales \
#     && /var/www/html/glpi/vendor/tecnickcom/tcpdf/tools/tcpdf_addfont.php -i /usr/share/fonts/truetype/fonts-chinese-gothic.ttf \
#     && /var/www/html/glpi/vendor/tecnickcom/tcpdf/tools/tcpdf_addfont.php -i /usr/share/fonts/truetype/fonts-chinese-mincho.ttf \
    && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

