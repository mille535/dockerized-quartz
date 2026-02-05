FROM node:lts-alpine

WORKDIR /usr/src/app

# Install required packages
RUN apk add --no-cache \
    nginx \
    git \
    inotify-tools \
    apache2-utils \
    curl \
    ca-certificates \
    apprise

COPY /scripts /usr/src/app/scripts
RUN chmod +x /usr/src/app/scripts/*

# Copy node server
COPY server.js /usr/src/app/
COPY package.json /usr/src/app/

RUN npm i

# Copy docs that will serve as an example vault content if no vault volume provided
COPY /docs /vault

# Expose port 80 for Nginx
EXPOSE 80

# Create Nginx config for serving the static files
RUN rm -f /etc/nginx/http.d/default.conf
COPY nginx.conf /etc/nginx/nginx.conf
RUN cp -R /etc/nginx/ /etc/nginx_default/

# Ensure directories exist for Nginx to serve static files and logs
RUN mkdir -p /usr/share/nginx/html /var/log/nginx && \
    chown -R nginx:nginx /usr/share/nginx/html

CMD ["/bin/sh", "-c", "/usr/src/app/scripts/bootstrap.sh"]