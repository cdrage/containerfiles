#Dockerfiles
Git repo for my personal Dockerfiles. README.md is auto-generated from Dockerfile comments
# ./jrl

```bash
# Encrypted journal (for writing, not logs!)
# docker run -it --rm -v /bin/txt.aes:/txt.aes jrl

```
# ./graphite

```bash
# docker run -d --name graphite -p 80:80 -p 2003:2003 -p 8125:8125/udp graphite/graphite

```
# ./samba

```bash
# source: https://github.com/JensErat/docker-samba-publicshare
# docker run -d  -p 445:445 -p 137:137 -p 138:138 -p 139:139 -v /data:/data --env workgroup=workgroup samba

```
# ./kubernetes

```bash

```
# ./tor

```bash

```
# ./dropbox

```bash
# docker run -d -e UID=$(id -u) -v ~/.dropbox:/home/.dropbox -v ~/dropbox:/home/Dropbox --name dropbox charliedrage/dropbox
# Remember to look at logs (docker logs dropbox) and click on the link!

```
# ./openvpn-client-docker

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
# ./peerflix

```bash
# docker run -it -p 8888:8888 wikus/peerflix "magnet shit:"

```
# ./tor-messenger

```bash
# Run tor messenger in a container
#
# docker run -d -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=unix$DISPLAY $USER/tor-messenger
#

```
# ./openvpn-client

```bash
# An openvpn-client in a container
# docker run -it -v /filesblahblah/hacktheplanet.ovpn:/etc/openvpn/hacktheplanet.ovpn --net=host --device /dev/net/tun:/dev/net/tun --cap-add=NET_ADMIN openvpn-client hacktheplanet.ovpn
# go check your public ip online and you'll see you're connected to the VPN :)

```
# ./sensu-client

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
# ./redis

```bash
# docker run --name redis -d -p 6379:6379 redis

```
# ./couchpotato

```bash
# docker run -d -p 5050:5050 --name couchpotato couchpotato

```
# ./consul

```bash

```
# ./mutt

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
# ./weechat

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
# ./nginx

```bash
# source: https://github.com/nginxinc/docker-nginx/blob/master/Dockerfile
# https://hub.docker.com/_/nginx/
#
# docker run --name some-nginx -v /some/content:/usr/share/nginx/html:ro -v /some/nginx.conf:/etc/nginx/nginx.conf:ro -p 80:80 -d nginx

```
# ./transmission

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
# ./firefox

```bash

```
# ./line

```bash
# You'll have to get LINE.exe first from somewhere ;)
# docker run --rm -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=unix$DISPLAY -H localhost charliedrage/line

```
# ./wifikill

```bash
# DISCLAIMER: Only use this on YOUR OWN network. This script is not responsible for any damages it causes.
# This uses ARP spoofing: https://en.wikipedia.org/wiki/ARP_spoofing by sending a fake MAC address to the victom believing it to be the gateway
# 
# To use:
# docker run --rm -it --net=host --cap-add=NET_ADMIN wifikill 

```
# ./nomad

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
# ./glances

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
# ./jekyll

```bash
# docker run --label=jekyll --volume=$(pwd):/srv/jekyll -d -p 80:4000 --restart=always jekyll/jekyll jekyll s

```
# ./plex

```bash
# source https://github.com/wernight/docker-plex-media-server
# mkdir ~/plex-config
# chown 797:797 -R ~/plex-config
# docker run -d -h server -v /root/plex-config:/config -v /data:/media -p 32400:32400 --net=host --name plex plex

```
# ./openvpn-server

```bash
# original: https://github.com/jpetazzo/dockvpn
# 
# CID=$(docker run -d --privileged -p 1194:1194/udp -p 443:443/tcp jpetazzo/dockvpn)
# docker run -t -i -p 8080:8080 --volumes-from $CID jpetazzo/dockvpn serveconfig
#
# curl IP:8080 for config then use your favourite openvpn client :)

```
