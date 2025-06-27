# Use Debian as base image
FROM debian:bullseye

# Environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV NVM_DIR=/root/.nvm

# Install base dependencies & add Sury PHP repo
RUN apt update && apt install -y \
    curl ca-certificates gnupg2 lsb-release wget unzip git make dos2unix sudo nginx \
    software-properties-common mariadb-client redis-server \
    && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list \
    && curl -fsSL https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/php.gpg \
    && apt update && apt install -y \
    php8.2 php8.2-{cli,fpm,mysql,mbstring,xml,curl,bcmath,zip,redis} \
    build-essential composer \
    && apt clean && rm -rf /var/lib/apt/lists/*

# Install NVM + Node.js 22 + Yarn
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash \
    && . "$NVM_DIR/nvm.sh" \
    && nvm install 22 \
    && nvm use 22 \
    && npm install -g yarn \
    && echo "source $NVM_DIR/nvm.sh" >> ~/.bashrc

# Set working directory
WORKDIR /var/www

# Copy panel files
COPY . .

# Build frontend
RUN . "$NVM_DIR/nvm.sh" && nvm use 22 && cd frontend && yarn install && yarn build

# Expose default web port
EXPOSE 80

# Start script
CMD ["bash", "./entrypoint.sh"]
