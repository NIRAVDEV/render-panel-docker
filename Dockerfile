# Use Debian as base
FROM debian:bullseye

# Install system dependencies
RUN apt update && apt install -y \
    curl ca-certificates gnupg2 lsb-release wget unzip git make dos2unix sudo nginx \
    software-properties-common mariadb-client redis-server build-essential \
    php php-fpm php-mysql php-mbstring php-xml php-curl php-bcmath php-zip php-redis \
    composer && \
    apt clean && rm -rf /var/lib/apt/lists/*

# Install NVM, Node.js 22 and Yarn
ENV NVM_DIR /root/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    . "$NVM_DIR/nvm.sh" && \
    nvm install 22 && \
    nvm use 22 && \
    npm install -g yarn && \
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc

# Clone MythicalDash and build it
RUN git clone https://github.com/MythicalLTD/MythicalDash /app && \
    cd /app && \
    bash -c ". /root/.nvm/nvm.sh && nvm use 22 && make install"

# Copy Nginx config
COPY default.conf /etc/nginx/sites-available/default

# Expose HTTP port
EXPOSE 80

# Start services
CMD service php7.4-fpm start && \
    service redis-server start && \
    service nginx start && \
    tail -f /dev/null
