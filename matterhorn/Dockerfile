# Description:
#
# A terminal interface for Mattermost via the client Matterhorn
# https://github.com/matterhorn-chat/matterhorn
#
# To run, simply supply a username, hostname and (additionally) a port number.
# For example:
# 
# Running:
#
# docker run -it --rm \
#  -e MM_USER=foobar@domain.com \
#  -e MM_PASS=foobar \
#  -e MM_HOST=gitlab.mattermost.com \
#  -e MM_PORT=443 \
#  --name matterhorn \
#  cdrage/matterhorn

FROM debian:sid

#! Dependencies
RUN apt-get update && apt-get install tar wget libtinfo-dev ncurses-bin bzip2 -y

#! Why they use libtinfoso.6 I do not know, so let's fake it till we make it
RUN ln -s /lib/x86_64-linux-gnu/libtinfo.so.5.9 /lib/x86_64-linux-gnu/libtinfo.so.6

#! Use 3.8
ENV RELEASE="https://github.com/matterhorn-chat/matterhorn/releases/download/30802.1.0/matterhorn-30802.1.0-Linux-x86_64.tar.gz"

RUN wget $RELEASE && \
      tar xf matterhorn*.tar.gz --strip 1

#! Copy over the entrypoint config generation script + config.ini
COPY entrypoint.sh /entrypoint.sh
COPY config.ini /config.ini
ENTRYPOINT ["/entrypoint.sh"]

#! Default environment variables
ENV MM_PORT=443

#! Run it!
CMD ["./matterhorn", "-c", "/config.ini"]
