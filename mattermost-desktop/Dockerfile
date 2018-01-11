# **Description:**
#
# **Source:** https://github.com/treemo/docker-mattermost-desktop/blob/master/Dockerfile
#
# **Running:**
#
# ```sh
# docker run \
#    -d \
#    -e DISPLAY \
#    -v /tmp/.X11-unix:/tmp/.X11-unix \
#    -v $HOME/.config/Mattermost:/home/user/.config/Mattermost \
#    --name mattermost-desktop \
#    cdrage/mattermost-desktop
# ```

FROM debian:sid

#! Version
ENV MATTERMOST_VERSION 3.5.0

#! Install
RUN apt update && apt install -y wget libgtk2.0-0 libxtst6 libxss1 libgconf-2-4 libnss3 libasound2
RUN cd /tmp && \
	wget https://releases.mattermost.com/desktop/$MATTERMOST_VERSION/mattermost-desktop-$MATTERMOST_VERSION-linux-x64.tar.gz && \
	tar xzvf mattermost-desktop-*.tar.gz && \
	mv mattermost-desktop-$MATTERMOST_VERSION/ /usr/lib/mattermost/

#! Clean
RUN apt remove --purge -y wget
RUN apt-get autoremove -y
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*
RUN rm -rf /tmp/* /var/tmp/*

#! Running
ENTRYPOINT ["/usr/lib/mattermost/mattermost-desktop"]
