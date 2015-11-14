# DNS cacher/forwarder
# Set IP as the forwarder :)
# docker run -p 53:53/udp -e IP=10.10.10.1 -d dnsmasq --name dnsmasq
# IP is the IP of the sniproxy / haproxy server

FROM ubuntu:trusty

RUN apt-get update -qq && apt-get install -y software-properties-common
RUN apt-get update -qq && apt-get install -y dnsmasq iptables

COPY entrypoint.sh /entrypoint.sh
COPY dnsmasq.conf /etc/dnsmasq.conf

EXPOSE 53

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/dnsmasq", "-k"]
