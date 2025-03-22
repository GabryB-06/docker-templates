FROM php:apache

RUN docker-php-ext-install mysqli
RUN a2enmod headers

ENTRYPOINT [ "apache2-foreground" ]