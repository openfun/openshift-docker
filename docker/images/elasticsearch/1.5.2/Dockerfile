FROM java:8-jre

RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 46095ACC8548582C1A2699A9D27D666CD88E42B4

ENV ELASTICSEARCH_MAJOR 1.5
ENV ELASTICSEARCH_VERSION ${ELASTICSEARCH_MAJOR}.2
ENV ELASTICSEARCH_REPO_BASE http://packages.elasticsearch.org/elasticsearch/${ELASTICSEARCH_MAJOR}/debian

RUN echo "deb $ELASTICSEARCH_REPO_BASE stable main" > /etc/apt/sources.list.d/elasticsearch.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends elasticsearch=$ELASTICSEARCH_VERSION && \
    rm -rf /var/lib/apt/lists/*

ENV PATH /usr/share/elasticsearch/bin:$PATH

WORKDIR /usr/share/elasticsearch

# Make sure that the initial directories exist and have the correct permissions
# for OpenShift.
# OpenShift will run the elasticsearch with a user with a random UID and a GID
# 0.
COPY config ./config

RUN for path in \
    ./data \
    ./logs \
    ./config \
    ./config/scripts; do \
    mkdir -p "$path"; \
    chgrp -R 0 "$path"; \
    chmod -R g=u "$path"; \
    done

# We use the elasticsearch user created during the .deb package installation to
# tell OpenShift that we're not running things as root.
USER elasticsearch

EXPOSE 9200 9300
ENTRYPOINT ["elasticsearch"]
