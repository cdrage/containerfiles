#
# recommended to daemonize it and run in background for collection of logs, etc while idle, simply attach to container.  ctrl+p ctrl+q to quit
#
# docker run -it -d -v /home/USER/.weechat:/root/.weechat \
# -v /etc/localtime:::/etc/localtime:ro \
# --name weechat \
# weechat
#
# docker attach


FROM ubuntu:14.10
MAINTAINER Charlie Drage <charlie@charliedrage.com>

RUN apt-get update && apt-get install -y \
  weechat \
  --no-install-recommends \
  && rm -rf /var/lib/apt/lists/*

ENV TERM screen-256color
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV C en_US.UTF-8

RUN mkdir -p /.weechat
VOLUME /.weechat
ENTRYPOINT ["weechat"]
