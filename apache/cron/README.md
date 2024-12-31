
# Cron

To add Cron to an Apache Docker container (or any other Docker container, make sure to replace `apache2-foreground` with the correct comamnd to start you container's main process in foreground, so the container doesn't get shut down) put `CMD ["/bin/sh", "-c", "/cron.sh && apache2-foreground"]` at the bottom of your Dockerfile and mount the script (eg `- ./cron.sh:/cron.sh:ro # Script for setup and Cron start` in docker-compose.yml)
