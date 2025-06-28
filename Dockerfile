FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV NVM_DIR=/root/.nvm
ENV NODE_VERSION=22
ENV PATH="$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH"

# Install dependencies
RUN apt update && apt install -y \
    software-properties-common curl wget git unzip zip gnupg2 lsb-release ca-certificates \
    nginx php8.2 php8.2-cli php8.2-fpm php8.2-mysql php8.2-curl php8.2-mbstring \
    php8.2-xml php8.2-zip php8.2-bcmath php8.2-gd php8.2-readline php8.2-common php8.2-sqlite3 php8.2-tokenizer \
    php8.2-opcache php8.2-soap php8.2-intl php8.2-pgsql build-essential

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

# Install NVM and Node.js 22
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    . "$NVM_DIR/nvm.sh" && \
    nvm install $NODE_VERSION && \
    nvm use $NODE_VERSION && \
    nvm alias default $NODE_VERSION && \
    npm install -g yarn

# Persist NVM path
RUN echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc

# Set working directory and copy project
WORKDIR /var/www/html
COPY . .

# Build frontend
RUN cd frontend && yarn install && yarn build

# Install backend dependencies
RUN cd backend && composer install --no-dev --optimize-autoloader

# Setup Nginx config
RUN rm /etc/nginx/sites-enabled/default && \
    echo 'server {
        listen 8080;
        root /var/www/html/frontend/dist;
        index index.html;
        location /api/ {
            proxy_pass http://localhost:9000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
        location / {
            try_files $uri /index.html;
        }
    }' > /etc/nginx/sites-available/default && \
    ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# Inline entrypoint to start services
RUN echo '#!/bin/bash\n\
set -e\n\
echo "[✅] Starting PHP-FPM..."\n\
/usr/sbin/php-fpm8.2 -D\n\
echo "[✅] Starting Nginx..."\n\
exec /usr/sbin/nginx -g "daemon off;"' > /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE 8080
CMD ["/entrypoint.sh"]
