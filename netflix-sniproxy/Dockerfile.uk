# DNS proxy (netflix unblocker) open source.
# fork of: https://github.com/trick77/dockerflix
#
# docker run -d -p 80:80 -p 443:443 --name sniproxy sniproxy
#
# build Dockerfile.uk for uk version

FROM phusion/baseimage:0.9.16
MAINTAINER trick77 <jan@trick77.com> https://trick77.com/

RUN apt-get -qq update
RUN apt-get -y install python-software-properties \
    && add-apt-repository ppa:dlundquist/sniproxy \
    && apt-get update && apt-get -y install sniproxy

RUN mkdir /etc/sniproxy
ADD ./config/uk-dockerflix-sniproxy.conf /etc/sniproxy/sniproxy.conf
RUN mkdir /etc/service/sniproxy
ADD ./config/run_sniproxy /etc/service/sniproxy/run
RUN chmod +x /etc/service/sniproxy/run

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 80 443
VOLUME ["/etc/sniproxy"]
VOLUME ["/var/log/sniproxy"]

CMD ["/sbin/my_init"]
