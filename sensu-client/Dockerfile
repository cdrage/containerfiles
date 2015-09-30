FROM debian:latest

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
  && apt-get upgrade -y \
  && apt-get install -y sensu \
  && apt-get install -y ruby ruby-dev build-essential git procps apt-utils bc \
  && gem install sensu-plugin redis docker docker-api etcd --no-rdoc --no-ri \
  && git clone git://github.com/sensu/sensu-community-plugins.git /community

ADD http://repos.sensuapp.org/apt/pubkey.gpg /tmp/pubkey.gpg
RUN \
ADD run.sh /tmp/run.sh
EXPOSE 3030
ENTRYPOINT ["/tmp/run.sh"]
