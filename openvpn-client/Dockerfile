# An openvpn-client in a container
# docker run -it -v /filesblahblah/hacktheplanet.ovpn:/etc/openvpn/hacktheplanet.ovpn --net=host --device /dev/net/tun:/dev/net/tun --cap-add=NET_ADMIN openvpn-client hacktheplanet.ovpn
# go check your public ip online and you'll see you're connected to the VPN :)

FROM alpine
RUN apk update && apk add openvpn
ENTRYPOINT ["openvpn"]
WORKDIR /etc/openvpn
