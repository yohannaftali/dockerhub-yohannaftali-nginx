FROM nginx:latest

LABEL github="https://github.com/yohannaftali/dockerhub-yohannaftali-nginx"

# Remove sym links from nginx image
RUN rm /var/log/nginx/access.log
RUN rm /var/log/nginx/error.log

# Install logrotate
RUN apt-get update && apt-get -y install logrotate

#Copy logrotate nginx configuration
COPY nginx /etc/logrotate.d/


# Start nginx and cron as a service
CMD service cron start && nginx -g 'daemon off;'