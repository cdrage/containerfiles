# **Description:**
#
# This is used to create a DNS cacher/forwarder in order to
# spoof the location when accessing Netflix. Similar to how a
# VPN does it, but this is with DNS.
#
# IP is the IP of the sniproxy / haproxy server
# if you're running it on the same host, it's your ip (eth0 or whatever).
#
# WARNING: it's a *really* bad idea to run an open recurse DNS server 
# (prone to DNS DDoS aplification attacks), it's suggested to have some 
# form of IP firewall for this. (hint: just use iptables)
#
# **Running:**
#
# ```sh
# docker run \
#   -p 53:53/udp \
#   -e IP=10.10.10.1 \
#   --name dnsmasq
#   -d \
#   cdrage/dnsmasq
# ```

FROM ubuntu:trusty

RUN apt-get update -qq && apt-get install -y software-properties-common
RUN apt-get update -qq && apt-get install -y dnsmasq iptables

COPY entrypoint.sh /entrypoint.sh
COPY dnsmasq.conf /etc/dnsmasq.conf

EXPOSE 53

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/dnsmasq", "-k"]
