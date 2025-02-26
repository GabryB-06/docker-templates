
# Cron

To add Cron to an Apache Docker container (or any other Docker container, make sure to replace `apache2-foreground` with the correct comamnd to start you container's main process in foreground mode, so the container doesn't get shut down) put
```docker
CMD ["/bin/sh", "-c", "/cron.sh && apache2-foreground"]
```
at the bottom of your Dockerfile and mount the script.

> [!WARNING]
> Remember to install `cron` in the container, for example using `apt install cron`, along with any non-default tools your cronjob requires.

---

> [!TIP]
> Example configuration for docker-compose.yml:
> ```docker
> # docker-compose.yml
>services:
>
>  apache:
>    build:
>      context: .
>      dockerfile: Dockerfile
>    image: apache-with-cron
>    ports:
>      - "80:80" # HTTP port
>    volumes:
>      - ./cron.sh:/cron.sh:ro
> ```
>
> Example Dockerfile:
> ```docker
> # Dockerfile
> FROM php:apache
>
> RUN apt-get update && \
>    apt-get install -y --no-install-recommends cron curl && \
>    apt-get clean && \
>    rm -rf /var/lib/apt/lists/*
>
> CMD ["/bin/sh", "-c", "/cron.sh && apache2-foreground"]
> ```
>
> Make sure the cron.sh file contains the necessary commands to set up and start Cron. For example:
>
> ```bash
> # cron.sh
> # Cronjob executed every minute
> echo "* * * * * curl http://127.0.0.1/internal/example.php -s | sed 's/^/Cronjob | /' > /proc/1/fd/1 2>/proc/1/fd/2" > "/var/spool/cron/crontabs/root"
> # Cronjob executed after every container reboot after a 20 seconds delay
> echo "@reboot sleep 20 && curl http://127.0.0.1/internal/example.php -s | sed 's/^/Cronjob | /' > /proc/1/fd/1 2>/proc/1/fd/2" >> "/var/spool/cron/crontabs/root"
> chmod 600 /var/spool/cron/crontabs/root
> chgrp crontab /var/spool/cron/crontabs/root
> cron
> ```
>
> The shell script provided in this example creates two cronjobs
>
> 1. executes a `curl` to the webserver hosted by the container itself every minute, this behaivour can be changed by editing the cronjob using the usual Cron syntax.
> 2. executes a `curl` like above to localhost but instead, just once after the container has been started (`@reboot`), with a delay of 20 seconds (`sleep 20`).
>
> Both cronjobs forward the output by the webserver output to Docker's log
