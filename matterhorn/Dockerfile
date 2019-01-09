# **Description:**
#
# A terminal interface for Mattermost via the client Matterhorn
# https://github.com/matterhorn-chat/matterhorn
#
# To run, simply supply a username, hostname and (additionally) a port number.
# For example:
# 
# **Running:**
#
# ```sh
# docker run -it --rm \
#  -e MM_USER=foobar@domain.com \
#  -e MM_PASS=foobar \
#  -e MM_HOST=gitlab.mattermost.com \
#  -e MM_PORT=443 \
#  --name matterhorn \
#  cdrage/matterhorn
# ```

FROM ubuntu:18.04

#! Dependencies
RUN apt-get update && apt-get install tar wget libtinfo-dev ncurses-bin bzip2 iputils-ping ca-certificates netbase -y

#! Why they use libtinfoso.6 I do not know, so let's fake it till we make it
#! RUN ln -s /lib/x86_64-linux-gnu/libtinfo.so.6.1 /lib/x86_64-linux-gnu/libtinfo.so.5

#! Use release
ENV RELEASE="https://github.com/matterhorn-chat/matterhorn/releases/download/50200.0.0/matterhorn-50200.0.0-Ubuntu-x86_64.tar.bz2"

RUN wget $RELEASE && \
      tar xf matterhorn*.tar.bz2 --strip 1

#! Copy over the entrypoint config generation script + config.ini
COPY entrypoint.sh /entrypoint.sh
COPY config.ini /config.ini
ENTRYPOINT ["/entrypoint.sh"]

#! Default environment variables
ENV MM_PORT=443

#! Run it!
CMD ["./matterhorn", "-c", "/config.ini"]
