# Base image
FROM debian:bullseye

# Set environment variable to noninteractive for silent apt installs
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt update --fix-missing && apt install -y \
    curl ca-certificates gnupg2 lsb-release wget unzip git make dos2unix sudo nginx \
    software-properties-common mariadb-server mariadb-client redis-server \
    php php-cli php-fpm php-mysql php-mbstring php-xml php-curl php-bcmath php-zip php-redis \
    build-essential composer nano

# Remove default nginx site and write new config
RUN rm /etc/nginx/sites-enabled/default && \
    bash -c 'cat > /etc/nginx/sites-enabled/default' <<EOF
server {
    listen 8080;
    root /var/www/html/frontend/dist;
    index index.html;
    location / {
        try_files \$uri \$uri/ /index.html;
    }
}
EOF

# Copy project files
COPY . /var/www/html

# Expose port
EXPOSE 8080

# Start services
CMD service php7.4-fpm start && service mariadb start && service redis-server start && nginx -g "daemon off;"
