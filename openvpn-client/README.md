 **Description:**

 An openvpn-client in an Alpine Linux container

 go check your public ip online and you'll see you're connected to the VPN :)

 **Running:**

 ```sh
 podman run -it 
 -v /filesblahblah/hacktheplanet.ovpn:/etc/openvpn/hacktheplanet.ovpn \
 --net=host --device /dev/net/tun:/dev/net/tun --cap-add=NET_ADMIN \
 cdrage/openvpn-client hacktheplanet.ovpn
 ```
