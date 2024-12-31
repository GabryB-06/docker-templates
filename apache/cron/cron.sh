# Cronjob executed every minute
echo "* * * * * curl http://127.0.0.1/internal/example.php -s | sed 's/^/Cronjob | /' > /proc/1/fd/1 2>/proc/1/fd/2" > /var/spool/cron/crontabs/root
# Cronjob executed after every container reboot after a 20 seconds delay
echo "@reboot sleep 20 && curl http://127.0.0.1/internal/example.php -s | sed 's/^/Cronjob | /' > /proc/1/fd/1 2>/proc/1/fd/2" >> /var/spool/cron/crontabs/root
chmod 600 /var/spool/cron/crontabs/root
chgrp crontab /var/spool/cron/crontabs/root
echo "Cron started"
cron
