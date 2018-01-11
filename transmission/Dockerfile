# **Description:**
#
# *Source:** https://github.com/dperson/transmission
# 
# ```
# ENV VARIABLES
# TRUSER - set username for transmission auth
# TRPASSWD - set password for transmission auth
# TIMEZONE - set zoneinfo timezone
# ```
#
# **Running:**
#
# ```sh
# docker run \
#   --name transmission \
#   -p 9091:9091 \
#   -v ~/Downloads:/var/lib/transmission-daemon/downloads \
#   -e TRUSER=admin \
#   -e TRPASSWD=admin \
#   -d \
#   cdrage/transmission
# ```

FROM debian:jessie
LABEL maintainer="Charlie Drage <charlie@charliedrage.com>"

RUN export DEBIAN_FRONTEND='noninteractive' && \
    apt-get update -qq && \
    apt-get install -qqy --no-install-recommends transmission-daemon curl \
                $(apt-get -s dist-upgrade|awk '/^Inst.*ecurity/ {print $2}') &&\
    apt-get clean && \
    usermod -d /var/lib/transmission-daemon debian-transmission && \
    [ -d /var/lib/transmission-daemon/downloads ] || \
                mkdir -p /var/lib/transmission-daemon/downloads && \
    [ -d /var/lib/transmission-daemon/incomplete ] || \
                mkdir -p /var/lib/transmission-daemon/incomplete && \
    [ -d /var/lib/transmission-daemon/info/blocklists ] || \
                mkdir -p /var/lib/transmission-daemon/info/blocklists && \
    chown -Rh debian-transmission. /var/lib/transmission-daemon && \
    rm -rf /var/lib/apt/lists/* /tmp/*
COPY transmission.sh /usr/bin/

VOLUME ["/run", "/tmp", "/var/cache", "/var/lib", "/var/log", "/var/tmp"]

EXPOSE 9091 51413/tcp 51413/udp

ENTRYPOINT ["transmission.sh"]
