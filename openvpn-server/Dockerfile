# **Description:**
#
# **Source:** https://github.com/jpetazzo/dockvpn
#
# NOTE:
# The keys are generate on EACH reboot and the private key is used in both the server
# and the client for simplicity reasons. If someone obtains your client information, they will be able 
# to access the server and perhaps spoof a session. It's recommended that you find an alternative way
# of deploying a VPN server if you are keen to have 100% security.
#
# If you wish to re-generate the certificates, simply restart your Docker container.
#
# **Running:**
#
# Start the openvpn server:
# ```sh
# docker run -d --privileged -p 1194:1194/udp -p 443:443/tcp --name vpn cdrage/openvpn-server
# ```
#
# Create a http server to termporarily download the configuration:
# ```sh
# docker run --rm -ti -p 8080:8080 --volumes-from vpn cdrage/openvpn-server serveconfig
# ```
#
# Download the configuration for your client to use:
# ```sh
# wget https://IP:8080/ --no-check-certificate -O config.ovpn
# ```

FROM ubuntu:precise
RUN echo deb http://archive.ubuntu.com/ubuntu/ precise main universe > /etc/apt/sources.list.d/precise.list
RUN apt-get update -q
RUN apt-get install -qy openvpn iptables socat curl
ADD ./bin /usr/local/sbin
VOLUME /etc/openvpn
EXPOSE 443/tcp 1194/udp 8080/tcp
CMD run
