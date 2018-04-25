FROM nginx:1.13

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="openshift-nginx" \
      org.label-schema.description="OpenShift-compatible nginx Docker image" \
      org.label-schema.url="https://github.com/openfun" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/openfun/openshift-docker" \
      org.label-schema.vendor="GIP FUN MOOC" \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"

# Allow nginx to be started by a non privileged user
RUN touch /var/run/nginx.pid && \
    chgrp -R 0 /var/run/nginx.pid /var/cache/nginx && \
    chmod -R g=u /var/run/nginx.pid /var/cache/nginx
