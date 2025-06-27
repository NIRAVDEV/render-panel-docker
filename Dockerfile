FROM debian:bullseye

LABEL maintainer="you@example.com"
WORKDIR /app

# Install base dependencies and PHP 8.2 (Sury repo)
RUN apt update && apt install -y \
    curl ca-certificates gnupg2 lsb-release wget unzip git make dos2unix sudo nginx \
    software-properties-common mariadb-client redis-server \
    && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list \
    && curl -fsSL https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/php.gpg \
    && apt update && apt install -y \
    php8.2 php8.2-cli php8.2-fpm php8.2-mysql php8.2-mbstring php8.2-xml \
    php8.2-curl php8.2-bcmath php8.2-zip php8.2-redis \
    build-essential composer \
    && apt clean && rm -rf /var/lib/apt/lists/*

# Install Node.js 22 and Yarn using NVM
ENV NVM_DIR=/root/.nvm
ENV NODE_VERSION=22

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    . "$NVM_DIR/nvm.sh" && \
    nvm install $NODE_VERSION && \
    nvm use $NODE_VERSION && \
    npm install -g yarn && \
    ln -s $NVM_DIR/versions/node/v$NODE_VERSION/bin/node /usr/bin/node && \
    ln -s $NVM_DIR/versions/node/v$NODE_VERSION/bin/npm /usr/bin/npm && \
    ln -s $NVM_DIR/versions/node/v$NODE_VERSION/bin/yarn /usr/bin/yarn

# Clone and setup MythicalDash v3
RUN git clone https://github.com/MythicalLTD/MythicalDash /app && \
    cd /app && make install

# Expose ports for web and API
EXPOSE 80 443 6000

# Start command (you can change this based on how MythicalDash starts)
CMD ["bash"]
