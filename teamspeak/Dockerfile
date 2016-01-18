# Source: https://github.com/luzifer-docker/docker-teamspeak3
#
# To run:
# docker run --name TS3 -d -p 9987:9987/udp -v ~/ts3:/teamspeak3 --restart=always $USER/ts3
# 
# All your files will be located within ~/ts3 (sqlite database, whitelist, etc.)
# To find out the admin key, use docker logs

FROM ubuntu:15.02

RUN apt-get update \
        && apt-get install -y wget --no-install-recommends \
        && rm -r /var/lib/apt/lists/*

ENV TEAMSPEAK_VERSION 3.0.11.4
ENV TEAMSPEAK_SHA1 09e7fc2cb5dddf84f3356ddd555ad361f5854321

VOLUME ["/teamspeak3"]

RUN wget -O teamspeak3-server_linux-amd64.tar.gz http://dl.4players.de/ts/releases/${TEAMSPEAK_VERSION}/teamspeak3-server_linux-amd64-${TEAMSPEAK_VERSION}.tar.gz \
        && echo "${TEAMSPEAK_SHA1} *teamspeak3-server_linux-amd64.tar.gz" | sha1sum -c - \
        && tar -C /opt -xzf teamspeak3-server_linux-amd64.tar.gz \
        && rm teamspeak3-server_linux-amd64.tar.gz

ADD /scripts/ /opt/scripts/
RUN chmod -R 774 /opt/scripts/

ENTRYPOINT ["/opt/scripts/docker-ts3.sh"]

EXPOSE 9987/udp
EXPOSE 30033 
EXPOSE 10011
