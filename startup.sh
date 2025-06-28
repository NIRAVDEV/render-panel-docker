#!/bin/bash

# Start PHP & Nginx
service php8.2-fpm start
service nginx start
service redis-server start
nginx -g "daemon off;"

# Optional: start queue (if required by MythicalDash)
# php artisan queue:work &

# Prevent container from exiting
tail -f /dev/null
