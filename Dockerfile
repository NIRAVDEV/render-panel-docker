FROM debian:bullseye

# Set environment
ENV DEBIAN_FRONTEND=noninteractive
ENV NVM_DIR=/root/.nvm

# Install base packages
RUN apt update && apt install -y \
    curl ca-certificates gnupg2 lsb-release wget unzip git make dos2unix sudo nginx \
    software-properties-common mariadb-client redis-server \
    php php-cli php-fpm php-mysql php-mbstring php-xml php-curl php-bcmath php-zip php-redis \
    build-essential composer nano

# Add PHP repository (for php8.x on Debian Bullseye)
RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list && \
    curl -fsSL https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/php.gpg && \
    apt update && apt install -y php8.2 php8.2-fpm php8.2-cli php8.2-mysql php8.2-mbstring php8.2-xml \
    php8.2-curl php8.2-bcmath php8.2-zip php8.2-redis && \
    apt clean && rm -rf /var/lib/apt/lists/*

# Set PHP 8.2 as default
RUN update-alternatives --set php /usr/bin/php8.2 && \
    update-alternatives --set phpize /usr/bin/phpize8.2 && \
    update-alternatives --set php-config /usr/bin/php-config8.2

# Install Node.js 22 and Yarn using NVM
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    . "$NVM_DIR/nvm.sh" && nvm install 22 && nvm use 22 && npm install -g yarn

# Clone MythicalDash
RUN git clone https://github.com/MythicalLTD/MythicalDash /app
WORKDIR /app

# Install panel dependencies
RUN bash -c ". $NVM_DIR/nvm.sh && nvm use 22 && make install"

# Copy nginx config
COPY default.conf /etc/nginx/sites-enabled/default

# Expose port
EXPOSE 80

# Start all services
CMD service php8.2-fpm start && \
    service redis-server start && \
    service nginx start && \
    tail -f /dev/null
