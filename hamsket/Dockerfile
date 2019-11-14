# **Description:**
#
# Run Hamsket in a container (multi-app chat tool)
#
# **Running:**
#
# ```sh
# docker run -d \
#  -v /tmp/.X11-unix:/tmp/.X11-unix \
#  -e DISPLAY=unix$DISPLAY \
#  -v /dev/shm:/dev/shm \
#  --device /dev/dri \
#  --name hamsket \
#  cdrage/hamsket
# ```


FROM debian:buster
LABEL maintainer="Charlie Drage <charlie@charliedrage.com>"

RUN apt-get -o Acquire::Check-Valid-Until=false update && apt-get install -y \
    wget libgtk2.0-0 libx11-xcb1 libxtst6 libxss1 libgconf-2-4 libnss3 libasound2 ca-certificates libgtk-3-0 \
    --no-install-recommends

ENV HOME /home/hamsket
RUN useradd --create-home --home-dir $HOME hamsket \
    && gpasswd -a hamsket hamsket \
    && chown -R hamsket:hamsket $HOME

USER hamsket
WORKDIR $HOME

ENV RELEASE https://github.com/TheGoddessInari/hamsket/releases/download/nightly/hamsket-0.6.0.tar.gz

RUN wget $RELEASE -O hamsket.tar.gz

RUN tar -zxvf hamsket.tar.gz --strip-components=1

ENV config /home/hamsket/.config/Hamsket
RUN mkdir -p "$config" \
    && chown -R hamsket:hamsket "$config"

USER root
RUN chown root:root chrome-sandbox \
    && chmod 4755 chrome-sandbox

USER hamsket 

VOLUME /home/hamsket/.config/Hamset

ENTRYPOINT  [ "./hamsket" ]
