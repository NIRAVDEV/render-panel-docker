Base image

FROM debian:bullseye

Set environment variables

ENV DEBIAN_FRONTEND=noninteractive

Install base packages with retry and --fix-missing

RUN apt update && 
apt install -y --fix-missing 
curl ca-certificates gnupg2 lsb-release wget unzip git make dos2unix sudo nginx 
software-properties-common mariadb-client redis-server 
php php-cli php-fpm php-mysql php-mbstring php-xml php-curl php-bcmath php-zip php-redis 
build-essential composer nano || 
(sleep 5 && apt install -y --fix-missing 
curl ca-certificates gnupg2 lsb-release wget unzip git make dos2unix sudo nginx 
software-properties-common mariadb-client redis-server 
php php-cli php-fpm php-mysql php-mbstring php-xml php-curl php-bcmath php-zip php-redis 
build-essential composer nano)

Create web root directory

RUN mkdir -p /var/www/html

Copy backend files

COPY backend /var/www/html/backend

Copy frontend files

COPY frontend /var/www/html/frontend

Set working directory

WORKDIR /var/www/html/backend

Install PHP dependencies

RUN composer install --no-interaction --prefer-dist --optimize-autoloader

Expose port

EXPOSE 8080

Configure NGINX to serve frontend

RUN rm /etc/nginx/sites-enabled/default && 
echo "server {\n
listen 8080;\n
root /var/www/html/frontend/dist;\n
index index.html;\n
location /api {\n
proxy_pass http://localhost:8000;\n
proxy_set_header Host $host;\n
proxy_set_header X-Real-IP $remote_addr;\n
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n
}\n
location / {\n
try_files $uri $uri/ /index.html;\n
}\n}" > /etc/nginx/sites-available/default && 
ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/

Start all services

CMD service php7.4-fpm start && service nginx start && php -S 0.0.0.0:8000 -t /var/www/html/backend/public

