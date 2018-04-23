FROM nginx:1.13

# Allow nginx to be started by a non privileged user
RUN touch /var/run/nginx.pid && \
    chgrp -R 0 /var/run/nginx.pid /var/cache/nginx && \
    chmod -R g=u /var/run/nginx.pid /var/cache/nginx
