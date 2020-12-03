FROM docker.elastic.co/elasticsearch/elasticsearch:5.6.16

# Switch back to the root user to set permissions
USER root

# Make sure that the initial directories have the correct permissions
# for OpenShift. OpenShift will run the elasticsearch with a user wit
# a random UID and a GID 0.
RUN chgrp -R 0 "/usr/share/elasticsearch"; chmod -R g=u "/usr/share/elasticsearch";

# Random user ID so that OpenShift knows we don't run the process as root
USER 1001
