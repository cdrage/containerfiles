# **Description:**
# Seafile server
#
# Original source: https://github.com/strator-dev/docker-seafile
#
# **Running:**
#
# docker run \
# -d \
# -e "SEAFILE_VERSION=6.2.2" \
# -e "SEAFILE_ADMIN_EMAIL=root@root.com" \
# -e "SEAFILE_ADMIN_PASSWORD=YOURPASSWORD" \
# -e "SEAFILE_HOST=0.0.0.0" \
# -e "SEAFILE_PORT=8080" \
# -v "/var/seafile:/opt/seafile" \
# -p 0.0.0.0:8080:8080 \
# --name="seafile" \
# cdrage/seafile-server
#
#
# TODO: Write more documentation
# See: https://github.com/strator-dev/docker-seafile for more details on how to run the garbage collector, etc.



FROM phusion/baseimage:latest

ADD files /tmp/files
RUN /bin/bash /tmp/files/build-script.sh

EXPOSE 8080 

