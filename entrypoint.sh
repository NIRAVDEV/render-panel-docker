#!/bin/bash

# Load NVM and set Node 22
export NVM_DIR="/root/.nvm"
source "$NVM_DIR/nvm.sh"
nvm use 22

# Build frontend
cd /var/www/mythicaldash/frontend
yarn install --ignore-engines --force
yarn build

# Install backend
cd /var/www/mythicaldash/backend
composer install --no-interaction --prefer-dist

# Start PHP, NGINX, Redis
service php8.2-fpm start
service nginx start
service redis-server start

# Run panel setup (runs migrations, etc.)
cd /var/www/mythicaldash
php mythicaldash setup
php mythicaldash migrate
php mythicaldash pterodactyl configure
php mythicaldash init

# Create default admin
php mythicaldash makeAdmin

# Keep container alive
tail -f /dev/null
