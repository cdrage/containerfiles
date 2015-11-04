# Original Source: https://github.com/arypurnomoz/sensu-client.docker
#
# This container allows you to run sensu in a container (yay) although there are some caveats.
#
# This is a basic container with NO checks. This is enough to get you setup and connecting to the sensu master. However, in order to add checks you'd have to pass in a folder of plugins (if you wish to pass them as a volume) or add them HERE to the Dockerfile.
#
# You'll also have to modify the checks.json file on the sensu master server in order to make sure you are using the correct plugins in the respective folders.
#
# docker run \
#  -v /ssl:/etc/sensu/ssl \
#  -e CLIENT_ADDRESS=10.0.0.1 \
#  -e CLIENT_NAME=sensu-client \
#  -e RABBITMQ_HOST=rabbitmq.local \
#  -e RABBITMQ_PORT=5671 \
#  -e RABBITMQ_USER=sensu \
#  -e RABBITMQ_PASS=sensu \
#  -e SUB=metrics,check \
#  sensu-client
#
# or use the Makefile provided :)

FROM debian:latest

# DEFAULTS
ENV REDIS_POST 6379
ENV RABBITMQ_PORT 5671
ENV RABBITMQ_VHOST /sensu
ENV RABBITMQ_USER sensu
ENV RABBITMQ_PASS sensu

ADD http://repos.sensuapp.org/apt/pubkey.gpg /tmp/pubkey.gpg

RUN \
  apt-key add /tmp/pubkey.gpg \
  && echo 'deb http://repos.sensuapp.org/apt sensu main' > /etc/apt/sources.list.d/sensu.list \
  && apt-get update \
  && apt-get install -y sensu \
  && apt-get install -y ruby ruby-dev build-essential git procps apt-utils bc wget ca-certificates \
  && gem install sensu-plugin redis docker docker-api etcd --no-rdoc --no-ri

ADD run.sh /tmp/run.sh
EXPOSE 3030
ENTRYPOINT ["/tmp/run.sh"]
