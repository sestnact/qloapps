FROM ubuntu:latest
LABEL Maintainer="Sesnact <support@sestnact.com>" \
      Description="Qloapps with Apache & PHP-FPM based on Ubuntu"

# Set variable
ENV PHP_VERSION="7.4"

# Install packages
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update\
    && apt update \
    && apt -y upgrade \
    && apt -y install software-properties-common wget unzip supervisor \
    && add-apt-repository ppa:ondrej/php \
    && apt-get update 

# Install Apache & PHP-FPM
RUN apt install -y apache2 apache2-utils libapache2-mod-fcgid \
    php${PHP_VERSION}-bcmath \
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-json \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-mcrypt \
    php${PHP_VERSION}-soap \
    php${PHP_VERSION}-gd \
    php${PHP_VERSION}-ldap \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-mysql \
    php${PHP_VERSION}-sqlite3 \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-zip \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-redis \
    php${PHP_VERSION}-imagick \
    php${PHP_VERSION}-simplexml 

# Setup Files
COPY include/apache2.conf /etc/apache2/apache2.conf
COPY include/qloapps.conf /etc/apache2/sites-available/qloapps.conf
COPY include/servername.conf /etc/apache2/conf-available/servername.conf
COPY include/php.ini /etc/php/${PHP_VERSION}/fpm/php.ini
COPY include/php-fpm.conf /etc/php/${PHP_VERSION}/fpm/php-fpm.conf
COPY include/www.conf /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf
COPY include/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY include/entrypoint.sh /entrypoint.sh

# Download Qloapps
RUN mkdir -p /usr/src \
    && mkdir -p /var/www/qloapps \
    && wget https://github.com/webkul/hotelcommerce/releases/download/v1.5.1/hotelcommerce.zip \
    && unzip hotelcommerce.zip -d /usr/src/ \
    && rm hotelcommerce.zip \
    && mv /usr/src/hotelcommerce /usr/src/qloapps \
# Setup Apache
    && a2enconf servername.conf \
    && a2enmod proxy \
    && a2enmod proxy_fcgi \
    && a2enconf php7.4-fpm \
    && a2enmod rewrite \
    && a2enmod headers \
    && a2dissite 000-default.conf \
    && a2ensite qloapps.conf \ 
    && mkdir /var/run/apache2 \ 
#Setup PHP-FPM   
    && mkdir -p /run/php/ \
    && touch /run/php/php${PHP_VERSION}-fpm.pid \
    && touch /run/php/php${PHP_VERSION}-fpm.sock \
# Setup Supervisor
    && chmod +x /etc/supervisor/conf.d/supervisord.conf \
# Setup Run.sh
    && chmod +x /entrypoint.sh \
# Cleanup
    && rm -rf /etc/apt/sources.list.d && rm -rf /tmp/* \
    && apt -y remove --purge wget \
    && apt autoclean \
    && apt -y autoremove

# Qloapps volume 
VOLUME /var/www/qloapps
WORKDIR /var/www/qloapps

EXPOSE 80 443 25
ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
