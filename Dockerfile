FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# === System packages & PHP PPA ===
RUN apt update && apt install -y \
    software-properties-common curl ca-certificates gnupg lsb-release && \
    add-apt-repository ppa:ondrej/php -y && \
    apt update && apt install -y \
    unzip git make dos2unix nginx mariadb-client redis-server \
    php8.2 php8.2-{cli,fpm,mysql,mbstring,xml,curl,bcmath,zip,redis} \
    build-essential && \
    apt clean && rm -rf /var/lib/apt/lists/*

# === Install NVM + Node.js 22 + Yarn ===
ENV NVM_DIR=/root/.nvm
ENV NODE_VERSION=22.0.0

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    . "$NVM_DIR/nvm.sh" && \
    nvm install $NODE_VERSION && \
    nvm use $NODE_VERSION && \
    nvm alias default $NODE_VERSION && \
    npm install -g yarn

ENV PATH=$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# === Install Composer globally ===
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer

# === Create app directory ===
WORKDIR /var/www/mythicaldash

# === Download MythicalDash release ===
RUN curl -Lo latest.zip https://github.com/MythicalLTD/MythicalDash/releases/latest/download/MythicalDash.zip && \
    unzip -o latest.zip && rm latest.zip

# === Install backend ===
WORKDIR /var/www/mythicaldash/backend
RUN composer install --no-dev

# === Install frontend ===
WORKDIR /var/www/mythicaldash/frontend
RUN yarn install && yarn build

# === Expose necessary ports ===
EXPOSE 80 443 6000

# === Startup Command (you can adjust this for production run logic) ===
CMD service mysql start && \
    service redis-server start && \
    service php8.2-fpm start && \
    service nginx start && \
    tail -f /dev/null
