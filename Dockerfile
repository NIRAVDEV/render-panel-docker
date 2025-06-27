FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV NVM_DIR=/root/.nvm

RUN apt update && apt upgrade -y && \
    apt install -y \
    curl ca-certificates gnupg software-properties-common unzip git make dos2unix \
    nginx mariadb-client redis-server \
    php8.2 php8.2-{cli,fpm,mysql,mbstring,xml,curl,bcmath,zip,redis} \
    build-essential && \
    apt clean && rm -rf /var/lib/apt/lists/*

# Set up your app after this...

# Install system dependencies
RUN apt update && apt install -y \
  curl ca-certificates gnupg software-properties-common unzip git make dos2unix nginx \
  php8.2 php8.2-{cli,fpm,mysql,mbstring,xml,curl,bcmath,zip,redis} \
  mariadb-client redis-server \
  build-essential

# Install NVM + Node.js 22 + Yarn
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
RUN bash -c "source /root/.nvm/nvm.sh && nvm install 22 && nvm alias default 22 && npm install -g yarn"

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Download and extract MythicalDash
WORKDIR /var/www/mythicaldash
RUN curl -Lo MythicalDash.zip https://github.com/MythicalLTD/MythicalDash/releases/latest/download/MythicalDash.zip \
  && unzip -o MythicalDash.zip -d . \
  && rm MythicalDash.zip

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80 443 6000

CMD ["/entrypoint.sh"]
