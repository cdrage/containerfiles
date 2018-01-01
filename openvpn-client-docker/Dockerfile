# **Description:**
#
# OpenVPN within an Ubuntu container
#
# Run then ctrl+p + ctrl+q after authenticating (this exists the container)
# 
# Then from another container just use `--net=container:openvpn`
# 
# Remember to add 
#
# ```
#  up /etc/openvpn/update-resolv-conf
#  down /etc/openvpn/update-resolv-conf
# ```
#
# to your `openvpn.conf` file!
#
# **Running:**
#
# ```sh
# docker run \
#   --cap-add=NET_ADMIN \
#   --device /dev/net/tun \
#   -h openvpn \
#   --name openvpn \
#   -it \
#   cdrage/openvpn-client-docker
#   ```

FROM ubuntu:14.04

RUN apt-get update -q
RUN apt-get install -qy openvpn iptables resolvconf

ADD update-resolv-conf /etc/openvpn/update-resolv-conf

ENTRYPOINT ["openvpn"]
WORKDIR /etc/openvpn
