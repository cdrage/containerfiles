# source https://github.com/wernight/docker-plex-media-server

# mkdir ~/plex-config
# chown 797:797 -R ~/plex-config
# docker run -d -h server -v $USER/plex-config:/config -v /data:/media -p 32400:32400 --net=host --name plex plex

FROM debian:jessie


RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y curl \
    && rm -rf /var/lib/apt/lists/*

RUN useradd --system --uid 797 -M --shell /usr/sbin/nologin plex

RUN touch /bin/start
RUN chmod +x /bin/start

RUN DOWNLOAD_URL=`curl -Ls https://plex.tv/downloads | grep -o '[^"'"'"']*amd64.deb' | grep -v binaries` && \
    echo $DOWNLOAD_URL && \
    curl -L $DOWNLOAD_URL -o plexmediaserver.deb
RUN dpkg -i plexmediaserver.deb
RUN rm -f plexmediaserver.deb

RUN rm -f /bin/start

RUN mkdir /config
RUN chown plex:plex /config

VOLUME /config
VOLUME /media

USER plex

EXPOSE 32400

ENV PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS 6

ENV PLEX_MEDIA_SERVER_MAX_STACK_SIZE 3000

ENV PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR /config

ENV PLEX_MEDIA_SERVER_HOME /usr/lib/plexmediaserver
ENV LD_LIBRARY_PATH /usr/lib/plexmediaserver
ENV TMPDIR /tmp

WORKDIR /usr/lib/plexmediaserver
CMD test -f /config/Plex\ Media\ Server/plexmediaserver.pid && rm -f /config/Plex\ Media\ Server/plexmediaserver.pid; \
    ulimit -s $PLEX_MAX_STACK_SIZE && ./Plex\ Media\ Server
