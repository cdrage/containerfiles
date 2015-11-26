#Dockerfiles
Git repo for my personal Dockerfiles. README.md is auto-generated from Dockerfile comments
### ./consul

```bash

```
### ./couchpotato

```bash
# docker run -d -p 5050:5050 --name couchpotato couchpotato

```
### ./dockerflix

```bash
# DNS proxy (netflix unblocker) open source.
# fork of: https://github.com/trick77/dockerflix
# 
#
#
# Create runit services
# Final cleanup
# Use baseimage-docker's init system.

```
### ./dropbox

```bash
# docker run -d -e UID=$(id -u) -v ~/.dropbox:/home/.dropbox -v ~/dropbox:/home/Dropbox --name dropbox charliedrage/dropbox
# Remember to look at logs (docker logs dropbox) and click on the link!

```
### ./firefox

```bash

```
### ./glances

```bash
# Run glances in a container
# SOURCE: https://github.com/nicolargo/glances
#
# docker run --rm -it \
#	--pid host \
#	--ipc host \
#	--net host \
#	--name glances \
#	charliedrage/glances

```
### ./graphite

```bash
# docker run -d --name graphite -p 80:80 -p 2003:2003 -p 8125:8125/udp graphite/graphite

```
### ./jekyll

```bash
# docker run --label=jekyll --volume=$(pwd):/srv/jekyll -d -p 80:4000 --restart=always jekyll/jekyll jekyll s

```
### ./jrl

```bash
# Encrypted journal (for writing, not logs!)
# docker run -it --rm -v /bin/txt.aes:/txt.aes jrl

```
### ./kubernetes

```bash

```
### ./libvirtd

```bash
# YAY! Libvirtd within Docker! USE DAT KVM VIRTUALIZATION
# Although this doesn't work very well at the moment (see KVM module errors)
#
# docker run
# --privileged \
# --net=host
# -p 16509:16509
# -v /var/lib/libvirt:/var/lib/libvirt
# --name libvirtd libvirtd
#
# to connect (on client): virsh --connect qemu+tcp://localhost/system

```
### ./line

```bash
# You'll have to get LINE.exe first from somewhere ;)
# docker run --rm -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=unix$DISPLAY -H localhost charliedrage/line

```
### ./moodle

```bash
#  source: https://github.com/playlyfe/docker-moodle
#
#  First, grab moodle and extract.
#  wget https://github.com/moodle/moodle/archive/v3.0.0.tar.gz
#  tar -xvf v3.0.0.tar.gz
#  mkdir /var/www
#  mv moodle-3.0.0 /var/www/html
#  
#  Now let's build the docker container
#  docker build -t moodle .
#  docker run -d --name moodle -p 80:80 -p 443:443 -p 3306:3306 -v /var/www/html:/var/www/html moodle
#
#  Permission dat shit
#  chmod -R 777 /var/www/html
#
#  Head over to localhost:80 and proceed through the installation (remember to create the config.php file too during install!)
#
#  MySQL username: moodleuser
#  password: moodle
#
#  All other values default :)
#
#  TODO: SSL stuffs

```
### ./mutt-gmail

```bash
# special thanks to jfrazelle for this config
#  docker run -it --rm \
#    -e TERM=xterm-256color \
#    -e MUTT \
#    -e MUTT_NAME \
#    -e MUTT_PASS \
#    -e MUTT_FROM \
#    -e MUTT_SMTP \
#    -e MUTT_IMAP \
#    -v $HOME/.gnupg:/home/user/.gnupg \
#    -v $HOME/dropbox/etc/aliases.txt:/home/user/.mutt/aliases.txt \
#    -v /etc/localtime:/etc/localtime:ro \
#    charliedrage/mutt

```
### ./netflix-dnsmasq

```bash
# DNS cacher/forwarder
# Set IP as the forwarder :)
# docker run -p 53:53/udp -e IP=10.10.10.1 -d dnsmasq --name dnsmasq
# IP is the IP of the sniproxy / haproxy server

```
### ./nginx

```bash
# source: https://github.com/nginxinc/docker-nginx/blob/master/Dockerfile
# https://hub.docker.com/_/nginx/
#
# docker run --name some-nginx -v /some/content:/usr/share/nginx/html:ro -v /some/nginx.conf:/etc/nginx/nginx.conf:ro -p 80:80 -d nginx

```
### ./nmap

```bash
# Original source: github.com/pandrew/dockerfiles
# build it yo:
# docker build -t nmap .
#
# and run it!
# docker run --rm -it --net=host --cap-add=NET_ADMIN nmap
#
# ex.
# docker run --rm -it --net=host --cap-add=NET_ADMIN nmap -v scanme.nmap.org

```
### ./nomad

```bash
# Nomad from Hashicorp. github.com/hashicorp/nomad
#
# To build the Nomad binary:
# git clone https://github.com/hashicorp/nomad
# cd nomad && make bin
#
# To use:
# docker run \
# --net=host \
# -v /run/docker.sock:/run/docker.sock \
# --name nomad \
# -p 4646:4646 \
# -p 4647:4647 \
# -p 4648:4648 \
# nomad agent -dev -network-interface YOURINTERFACE(eth0 probably)
#
# Now simply bash into it. Run ./nomad init && ./nomad run example.nomad
# and you'll see a redis container spring up on your host :)

```
### ./openvpn-client

```bash
# An openvpn-client in a container
# docker run -it -v /filesblahblah/hacktheplanet.ovpn:/etc/openvpn/hacktheplanet.ovpn --net=host --device /dev/net/tun:/dev/net/tun --cap-add=NET_ADMIN openvpn-client hacktheplanet.ovpn
# go check your public ip online and you'll see you're connected to the VPN :)

```
### ./openvpn-client-docker

```bash
# 
# docker run --cap-add=NET_ADMIN --device /dev/net/tun -h openvpn --name openvpn -it openvpn
# 
# then from another container just use --net=container:openvpn
# 
# remember to add 
#  up /etc/openvpn/update-resolv-conf
#  down /etc/openvpn/update-resolv-conf
#
#  to your openvpn conf file!

```
### ./openvpn-server

```bash
# original: https://github.com/jpetazzo/dockvpn
# 
# CID=$(docker run -d --privileged -p 1194:1194/udp -p 443:443/tcp openvpn)
# docker run -t -i -p 8080:8080 --volumes-from $CID opvenvpn serveconfig
#
# curl IP:8080 for config then use your favourite openvpn client :)

```
### ./peerflix

```bash
# docker run -it -p 8888:8888 wikus/peerflix "magnet shit:"

```
### ./plex

```bash
# source https://github.com/wernight/docker-plex-media-server
# mkdir ~/plex-config
# chown 797:797 -R ~/plex-config
# docker run -d -h server -v /root/plex-config:/config -v /data:/media -p 32400:32400 --net=host --name plex plex

```
### ./redis

```bash
# docker run --name redis -d -p 6379:6379 redis

```
### ./samba

```bash
# source: https://github.com/JensErat/docker-samba-publicshare
# docker run -d  -p 445:445 -p 137:137 -p 138:138 -p 139:139 -v /data:/data --env workgroup=workgroup samba

```
### ./sensu-client

```bash
# Original Source: https://github.com/arypurnomoz/sensu-client.docker
#
# This container allows you to run sensu in a container (yay) although there are some caveats.
#
# This is a basic container with NO checks. This is enough to get you setup and connecting to the sensu master. However, in order to add checks you'd have to pass in a folder of plugins (if you wish to pass them as a volume) or add them HERE to the Dockerfile.
#
# You'll also have to modify the checks.json file on the sensu master server in order to make sure you are using the correct plugins in the respective folders.
#
# docker run \
#  -v /ssl:/etc/sensu/ssl \
#  -e CLIENT_ADDRESS=10.0.0.1 \
#  -e CLIENT_NAME=sensu-client \
#  -e RABBITMQ_HOST=rabbitmq.local \
#  -e RABBITMQ_PORT=5671 \
#  -e RABBITMQ_USER=sensu \
#  -e RABBITMQ_PASS=sensu \
#  -e SUB=metrics,check \
#  sensu-client
#
# or use the Makefile provided :)
# DEFAULTS

```
### ./tor

```bash

```
### ./tor-messenger

```bash
# Run tor messenger in a container
#
# docker run -d -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=unix$DISPLAY $USER/tor-messenger
#

```
### ./transmission

```bash
# source: https://github.com/dperson/transmission
#
# docker run --name transmission -p 9091:9091 -v /path/to/directory:/var/lib/transmission-daemon/downloads -d transmission
#
# ENVIRO VARIABLES
# TRUSER - set username for transmission auth
# TRPASSWD - set password for transmission auth
# TIMEZONE - set zoneinfo timezone

```
### ./weechat

```bash
# recommended to daemonize it and run in background for collection of logs, etc while idle, simply attach to container.  ctrl+p ctrl+q to quit
#
# docker run -it -d \
# -e TERM=xterm-256color \
# -v /etc/localtime:/etc/localtime:ro \
# --name weechat \
# weechat
#
# docker attach weechat

```
### ./wifikill

```bash
# DISCLAIMER: Only use this on YOUR OWN network. This script is not responsible for any damages it causes.
# This uses ARP spoofing: https://en.wikipedia.org/wiki/ARP_spoofing by sending a fake MAC address to the victom believing it to be the gateway
# 
# To use:
# docker run --rm -it --net=host --cap-add=NET_ADMIN wifikill 

```
