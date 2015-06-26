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

# compile from source
RUN apt-get update && apt-get -y build-dep weechat
RUN apt-get -y install git
RUN apt-get -y install openssl ca-certificates
RUN git clone http://github.com/weechat/weechat
RUN mkdir weechat/build
RUN cd weechat/build && cmake .. -DCMAKE_BUILD_TYPE=Debug && make && make install

# Add support for emoji / full utf-8 width
ADD wcwidth.c wcwidth.c
RUN gcc -shared -fPIC -Dmk_wcwidth=wcwidth -Dmk_wcswidth=wcswidth -o libwcwidth.so wcwidth.c
ENV LD_PRELOAD /libwcwidth.so


# UTF-8 & term
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV C en_US.UTF-8
ENV TERM screen-256color

RUN mkdir -p /.weechat
ENTRYPOINT ["weechat-curses"]
