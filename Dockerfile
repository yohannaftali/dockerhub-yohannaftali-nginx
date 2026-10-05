ARG NGINX_VERSION=latest
FROM nginx:${NGINX_VERSION}

LABEL org.opencontainers.image.title="nginx" \
      org.opencontainers.image.description="Official nginx image rebuilt weekly for production use" \
      org.opencontainers.image.authors="Yohan Naftali" \
      org.opencontainers.image.source="https://github.com/yohannaftali/dockerhub-yohannaftali-nginx" \
      github="https://github.com/yohannaftali/dockerhub-yohannaftali-nginx"

# # Install logrotate
# RUN apt-get update && apt-get -y install logrotate

# #Copy logrotate nginx configuration
# COPY nginx /etc/logrotate.d/

# # Start nginx and cron as a service
# CMD service cron start && nginx -g 'daemon off;'
