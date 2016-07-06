# Couch Potato is a torrent grepper / downloader
#
# docker run -d -p 5050:5050 --name couchpotato couchpotato 
# 
# pass in -v ./couchpotato_config:/root/.couchpotato for persistent data

FROM debian:jessie
MAINTAINER Charlie Drage <charlie@charliedrage.com>

RUN apt-get update -qq && \
apt-get install -y git python && \
apt-get clean && \
echo -n > /var/lib/apt/extended_states

RUN mkdir -p /opt/couchpotato && \
git clone https://www.github.com/RuudBurger/CouchPotatoServer.git /opt/couchpotato

WORKDIR /opt/couchpotato
ENTRYPOINT ["python", "CouchPotato.py"]
EXPOSE 5050
