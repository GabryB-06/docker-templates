FROM php:apache

RUN apt-get update && \
    apt-get install -y --no-install-recommends unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
    
COPY --from=composer/composer:latest-bin /composer /usr/bin/composer
RUN cd / && composer require google/apiclient && composer clearcache

RUN docker-php-ext-install mysqli
RUN a2enmod headers ssl rewrite