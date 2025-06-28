#!/bin/bash

# Start services
service mariadb start
service redis-server start
service php7.4-fpm start

# Start nginx in foreground
nginx -g "daemon off;"
