# source: https://github.com/dperson/transmission
#
# docker run --name transmission -p 9091:9091 -v /path/to/directory:/var/lib/transmission-daemon/downloads -d transmission
#
# ENVIRO VARIABLES
# TRUSER - set username for transmission auth
# TRPASSWD - set password for transmission auth
# TIMEZONE - set zoneinfo timezone

FROM debian:jessie
MAINTAINER Charlie Drage <charlie@charliedrage.com>

RUN export DEBIAN_FRONTEND='noninteractive' && \
    apt-get update -qq && \
    apt-get install -qqy --no-install-recommends transmission-daemon curl \
                $(apt-get -s dist-upgrade|awk '/^Inst.*ecurity/ {print $2}') &&\
    apt-get clean && \
    usermod -d /var/lib/transmission-daemon debian-transmission && \
    [[ -d /var/lib/transmission-daemon/downloads ]] || \
                mkdir -p /var/lib/transmission-daemon/downloads && \
    [[ -d /var/lib/transmission-daemon/incomplete ]] || \
                mkdir -p /var/lib/transmission-daemon/incomplete && \
    [[ -d /var/lib/transmission-daemon/info/blocklists ]] || \
                mkdir -p /var/lib/transmission-daemon/info/blocklists && \
    chown -Rh debian-transmission. /var/lib/transmission-daemon && \
    rm -rf /var/lib/apt/lists/* /tmp/*
COPY transmission.sh /usr/bin/

VOLUME ["/var/lib/transmission-daemon"]

EXPOSE 9091 51413/tcp 51413/udp

ENTRYPOINT ["transmission.sh"]
