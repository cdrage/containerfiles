# **Description:**
#
# **Source:** https://github.com/luzifer-docker/docker-teamspeak3
#
# Praise Gaben! Teamspeak in a docker container :)
#
# All your files will be located within ~/ts (sqlite database, whitelist, etc.). 
# This is your persistent folder. This will containe your credentials, whitelist, etc. So keep it safe.
# If you ever want to upgrade your teamspeak server (dif version or hash), simply point the files to there again.
# To find out the admin key on initial boot. Use docker logs teamspeak
#
# **Running:**
#
# ```sh
# docker run \
#   --name teamspeak \
#   -d \
#   -p 9987:9987/udp \
#   -p 30033:30033/tcp \
#   -v $HOME/ts:/teamspeak3 \
#   cdrage/teamspeak
# ```

FROM ubuntu:16.04

MAINTAINER Alex

RUN apt-get update \
        && apt-get install -y wget bzip2 --no-install-recommends \
        && rm -r /var/lib/apt/lists/*

ENV TEAMSPEAK_VERSION 3.0.12.4
ENV TEAMSPEAK_SHA256 6bb0e8c8974fa5739b90e1806687128342b3ab36510944f576942e67df7a1bd9

VOLUME ["/teamspeak3"]

RUN wget -O teamspeak3-server_linux-amd64.tar.bz2 http://dl.4players.de/ts/releases/${TEAMSPEAK_VERSION}/teamspeak3-server_linux_amd64-${TEAMSPEAK_VERSION}.tar.bz2 \
        && echo "${TEAMSPEAK_SHA256} *teamspeak3-server_linux-amd64.tar.bz2" | sha256sum -c - \
        && tar -C /opt -xjf teamspeak3-server_linux-amd64.tar.bz2 \
        && rm teamspeak3-server_linux-amd64.tar.bz2

ADD /scripts/ /opt/scripts/
RUN chmod -R 774 /opt/scripts/

ENTRYPOINT ["/opt/scripts/docker-ts3.sh"]

EXPOSE 9987/udp
EXPOSE 30033
EXPOSE 10011
