# original: https://github.com/jpetazzo/dockvpn
# 
# CID=$(docker run -d --privileged -p 1194:1194/udp -p 443:443/tcp jpetazzo/dockvpn)
# docker run -t -i -p 8080:8080 --volumes-from $CID jpetazzo/dockvpn serveconfig
#
# curl IP:8080 for config then use your favourite openvpn client :)

FROM ubuntu:precise
RUN echo deb http://archive.ubuntu.com/ubuntu/ precise main universe > /etc/apt/sources.list.d/precise.list
RUN apt-get update -q
RUN apt-get install -qy openvpn iptables socat curl
ADD ./bin /usr/local/sbin
VOLUME /etc/openvpn
EXPOSE 443/tcp 1194/udp 8080/tcp
CMD run
