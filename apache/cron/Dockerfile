FROM php:apache

RUN apt-get update && \
    apt-get install -y --no-install-recommends cron curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

CMD ["/bin/sh", "-c", "/cron.sh && apache2-foreground"]
