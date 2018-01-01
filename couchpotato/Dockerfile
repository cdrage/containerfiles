# **Description:**
#
# Couch Potato is a torrent grepper / downloader
# Pass in `-v ./couchpotato_config:/root/.couchpotato` for persistent data
#
# **Running:**
#
# ```sh
# docker run -d \
#   -p 5050:5050 \
#   --name couchpotato \
#   cdrage/couchpotato 
# ```
#
# **Running with persistent data:**
#
# ```sh
# docker run -d \
#   -p 5050:5050 \
#   --name couchpotato \
#   -v ./couchpotato_config:/root/.couchpotato \
#   cdrage/couchpotato 
# ```
#

FROM debian:jessie
LABEL maintainer="Charlie Drage <charlie@charliedrage.com>"

RUN apt-get update -qq && \
  apt-get install -y git openssl curl ca-certificates python-pip python-dev libz-dev libxml2-dev libxslt1-dev gcc && \
  pip install cheetah lxml pyopenssl && \
  pip install pyopenssl --upgrade && \
  apt-get clean && \
  echo -n > /var/lib/apt/extended_states

RUN mkdir -p /opt/couchpotato && \
  git clone -b develop https://git@github.com/RuudBurger/CouchPotatoServer.git /opt/couchpotato

WORKDIR /opt/couchpotato
ENTRYPOINT ["python", "CouchPotato.py"]
EXPOSE 5050
