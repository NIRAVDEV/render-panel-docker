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
    listen 8080 default_server;
    root /var/www/html/public;

    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php7.4-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

# Copy project files
COPY . /var/www/html

# Expose port
EXPOSE 8080

# Start services
COPY start.sh /start.sh
RUN chmod +x /start.sh
CMD ["/start.sh"]
