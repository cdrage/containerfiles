# **Description:**
#
# **Source:** https://github.com/arypurnomoz/sensu-client.docker
#
# This container allows you to run sensu in a container (yay) although there are some caveats.
#
# This is a basic container with NO checks. This is enough to get you setup and connecting to the sensu master. However, in order to add checks you'd have to pass in a folder of plugins (if you wish to pass them as a volume) or add them HERE to the Dockerfile.
#
# In my example, I use the docker-api and docker folder since I'll be mounting a -v /checks folder containing a few plugins. This is all optional and you may modify it to your own will.
#
# You'll also have to modify the checks.json file on the sensu master server in order to make sure you are using the correct plugins in the respective folders.
#
#
# **Running:**
#
# ```sh
# docker run \
#  -v /etc/sensu/ssl/cert.pem:/etc/sensu/ssl/cert.pem \
#  -v /etc/sensu/ssl/key.pem:/etc/sensu/ssl/key.pem \
#  -v /etc/sensu/plugins:/etc/sensu/plugins \
#  -e CLIENT_NAME=sensu-client \
#  -e CLIENT_ADDRESS=10.0.0.1 \
#  -e RABBITMQ_HOST=rabbitmq.local \
#  -e RABBITMQ_PORT=5671 \
#  -e RABBITMQ_VHOST="/sensu" \
#  -e RABBITMQ_USER=sensu \
#  -e RABBITMQ_PASS=sensu \
#  -e SUB=metrics,check \
#  cdrage/sensu-client
# ```
#
# or use the Makefile provided.
# ex.
#
# ```sh
# make all SSL=/etc/sensu/ssl IP=10.10.10.1 NAME=sensu SUB=default RABBIT_HOST=10.10.10.10 RABBIT_USERNAME=sensu RABBIT_PASS=sensu
# ```

FROM debian:jessie

ENV DEBIAN_FRONTEND="noninteractive"

ENV REDIS_POST 6379
ENV RABBITMQ_PORT 5671
ENV RABBITMQ_VHOST /sensu
ENV RABBITMQ_USER sensu
ENV RABBITMQ_PASS sensu

RUN \
  apt-get update \
  && apt-get install -y wget \
  && wget -q http://repos.sensuapp.org/apt/pubkey.gpg -O- | apt-key add - \
  && echo 'deb http://repos.sensuapp.org/apt sensu main' > /etc/apt/sources.list.d/sensu.list \
  && apt-get update \
  && apt-get install -y ruby ruby-dev build-essential git procps apt-utils bc ca-certificates \
  && apt-get install -y sensu \
  && gem install sensu-plugin redis --no-rdoc --no-ri

#! Install misc packages (in my case, checking the docker port, thus needing docker + docker-api :)
#! RUN \
#!  gem install docker docker-api --no-rdoc --no-ri

ADD run.sh /tmp/run.sh
EXPOSE 3030
ENTRYPOINT ["/tmp/run.sh"]
