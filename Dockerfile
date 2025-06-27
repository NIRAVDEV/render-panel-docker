# Start with a base Debian image
FROM debian:bullseye

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV NVM_DIR=/root/.nvm
ENV NODE_VERSION=22

# Install required packages & Sury PHP repo (safe for Docker)
RUN apt update && apt install -y \
    curl ca-certificates gnupg2 lsb-release wget unzip git make dos2unix sudo nginx \
    mariadb-client redis-server php8.2 php8.2-{cli,fpm,mysql,mbstring,xml,curl,bcmath,zip,redis} \
    build-essential && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list && \
    curl -fsSL https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/php.gpg && \
    apt update && apt install -y php8.2 php8.2-{cli,fpm,mysql,mbstring,xml,curl,bcmath,zip,redis} && \
    apt clean && rm -rf /var/lib/apt/lists/*

# Install Node.js 22 with NVM + Yarn
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    . "$NVM_DIR/nvm.sh" && nvm install $NODE_VERSION && nvm use $NODE_VERSION && \
    npm install -g yarn && \
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set working directory
WORKDIR /var/www/mythicaldash

# Download and extract MythicalDash v3
RUN curl -Lo MythicalDash.zip https://github.com/MythicalLTD/MythicalDash/releases/latest/download/MythicalDash.zip && \
    unzip MythicalDash.zip -d . && rm MythicalDash.zip

# Build backend
WORKDIR /var/www/mythicaldash/backend
RUN composer install --no-dev

# Build frontend
WORKDIR /var/www/mythicaldash/frontend
RUN . "$NVM_DIR/nvm.sh" && nvm use $NODE_VERSION && yarn install && yarn build

# Expose web port
EXPOSE 80

# Entry point (replace this with custom command if needed)
CMD ["php-fpm8.2", "-F"]
