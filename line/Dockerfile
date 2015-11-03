# docker run --rm -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=unix$DISPLAY -H localhost charliedrage/line

FROM ubuntu:trusty

MAINTAINER Charlie Drage <charlie@charliedrage.com>

RUN dpkg --add-architecture i386
RUN apt-get update && \
  apt-get install p7zip-full xvfb wine -y

RUN sudo -H -u root bash -c "WINEARCH=win32 WINEPREFIX=~/.wine winecfg && \
xvfb-run winetricks --unattended vcrun2008"

ADD LINE /LINE
RUN ls /LINE

CMD wine /LINE/LINE.exe
