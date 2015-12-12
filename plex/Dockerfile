# source https://github.com/wernight/docker-plex-media-server

# mkdir ~/plex-config
# chown 797:797 -R ~/plex-config
# docker run -d -v /root/plex-config:/config -v /data:/media -p 32400:32400 --net=host --name plex plex
#
# Note:
# If you are using this on a remote server (VPS and such), you must edit Preferences.xml within the plex-config 
# folder and add your network within <Preferences> allowedNetworks="192.168.1.0/255.255.255.0" if you wish
# to set this up remotely
#
# Or you can simply SSH portforward to the server to configure everything

FROM debian:jessie

RUN useradd --system --uid 797 -M --shell /usr/sbin/nologin plex \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
 && DOWNLOAD_URL=`curl -Ls https://plex.tv/downloads \
    | grep -o '[^"'"'"']*amd64.deb' \
    | grep -v binaries` \
 && echo $DOWNLOAD_URL \
 && curl -L $DOWNLOAD_URL -o plexmediaserver.deb \
 && touch /bin/start \
 && chmod +x /bin/start \
 && dpkg -i plexmediaserver.deb \
 && rm -f plexmediaserver.deb \
 && rm -f /bin/start \
 && apt-get purge -y --auto-remove \
        curl \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir /config \
 && chown plex:plex /config

VOLUME /config
VOLUME /media

EXPOSE 32400

ENV PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS 6

ENV PLEX_MEDIA_SERVER_MAX_STACK_SIZE 3000

ENV PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR /config

ENV PLEX_MEDIA_SERVER_HOME /usr/lib/plexmediaserver
ENV LD_LIBRARY_PATH /usr/lib/plexmediaserver
ENV TMPDIR /tmp

ADD *.sh /

USER plex

WORKDIR /usr/lib/plexmediaserver
ENTRYPOINT ["/entrypoint.sh"]
CMD ./Plex\ Media\ Server
