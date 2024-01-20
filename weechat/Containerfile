# **Description:**
#
# Weechat IRC!
#
# recommended to daemonize it and run in background for collection of logs, etc while idle, simply attach to container.  ctrl+p ctrl+q to quit
#
# port 40900 is used for weechat relay (if you decide to use it)
#
# run then `docker attach weechat`
#
# **Running:**
#
# ```sh
# docker run -it -d \
#   -e TERM=xterm-256color \
#   -v /etc/localtime:/etc/localtime:ro \
#   --name weechat \
#   -p 40900:40900 \
#   cdrage/weechat
# ```

FROM ubuntu:16.04
LABEL maintainer="Charlie Drage <charlie@charliedrage.com>"

RUN apt-get update 
RUN apt-get -y build-dep weechat
RUN apt-get -y install locales git openssl ca-certificates
RUN git clone http://github.com/weechat/weechat
RUN mkdir weechat/build
RUN cd weechat/build && cmake .. -DCMAKE_BUILD_TYPE=Debug && make && make install

ADD wcwidth.c wcwidth.c
RUN gcc -shared -fPIC -Dmk_wcwidth=wcwidth -Dmk_wcswidth=wcswidth -o libwcwidth.so wcwidth.c
ENV LD_PRELOAD /libwcwidth.so

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV C en_US.UTF-8
ENV TERM screen-256color

RUN mkdir -p /.weechat

ADD weechat.conf /root/.weechat/weechat.conf

ENTRYPOINT ["weechat-curses"]
