# Dockerfiles
Welcome! This is a list of Dockerfiles that I use. Some are ones that I have created, other's have been modified for my usage.

Each container is automatically built and pushed to [https://hub.docker.com/r/cdrage/](https://hub.docker.com/r/cdrage/) upon each commit.

Otherwise, you may also `git clone https://github.com/cdrage/dockerfiles` and build it yourself.

Below is a general overview (with instructions) on each Docker container I use. This is automatically generated from the comments that I have left in each `Dockerfile`.


### ./chrome

```
 Description:

 Run Chrome in a container (thx jess)

 Note: Disabled sandbox due to running-in-a-container issue with userns 
 enabled in kernel, see: https://github.com/jfrazelle/dockerfiles/issues/149

 Running:

 docker run -d \
   --memory 3gb \
   -v /etc/localtime:/etc/localtime:ro \
   -v /tmp/.X11-unix:/tmp/.X11-unix \
   -e DISPLAY=unix$DISPLAY \
   -v $HOME/.chrome:/data \
   -v $HOME/docker_files/chrome_downloads:/root/Downloads \
   -v /dev/shm:/dev/shm \
   --device /dev/dri \
   --name chrome \
   cdrage/chrome

```
### ./couchpotato

```
 Description:

 Couch Potato is a torrent grepper / downloader
 Pass in -v ./couchpotato_config:/root/.couchpotato for persistent data

 Running:

 docker run -d \
   -p 5050:5050 \
   --name couchpotato \
   cdrage/couchpotato 

```
### ./jrl

```
 Description:

 Encrypted journal (for writing your life entries!, not logs!)
 
 Pass in your encrypted txt file and type in your password.
 It'll then open it up in vim for you to edit and type up your
 latest entry.

 Remember, this is aes-256-cbc, so it's like hammering a nail
 with a screwdriver: 
 http://stackoverflow.com/questions/16056135/how-to-use-openssl-to-encrypt-decrypt-files

 Public / Private key would be better, but hell, this is just a txt file.
 
 Now run it!

 Running:

 docker run -it --rm \
   -v ~/txt.enc:/tmp/txt.enc \
   -v /etc/localtime:/etc/localtime:ro \
   cdrage/jrl

```
### ./matterhorn

```
 Description:

 A terminal interface for Mattermost via the client Matterhorn
 https://github.com/matterhorn-chat/matterhorn

 To run, simply supply a username, hostname and (additionally) a port number.
 For example:
 
 Running:

 docker run -it --rm \
  -e MM_USER=foobar@domain.com \
  -e MM_HOST=gitlab.mattermost.com \
  -e MM_PORT=443 \
  --name matterhorn \
  cdrage/matterhorn

```
### ./mattermost-desktop

```
 Description:

 Original source: https://github.com/treemo/docker-mattermost-desktop/blob/master/Dockerfile

 Running:

 docker run \
    -d \
    -e DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v $HOME/.config/Mattermost:/home/user/.config/Mattermost \
    --name mattermost-desktop \
    cdrage/mattermost-desktop

```
### ./moodle

```
  Description:

  source: https://github.com/playlyfe/docker-moodle

  First, grab moodle and extract.
  wget https://github.com/moodle/moodle/archive/v3.0.0.tar.gz
  tar -xvf v3.0.0.tar.gz
  mkdir /var/www
  mv moodle-3.0.0 /var/www/html
  
  Head over to localhost:80 and proceed through the installation (remember to create the config.php file too during install!)

  MySQL username: moodleuser
  password: moodle

  All other values default :)

  TODO: SSL stuffs

  Running:

  docker run -d \
   -p 80:80 \
   -p 443:443 \
   -p 3306:3306 \
   -v /var/www/html:/var/www/html \
   --name moodle \
   moodle

  Setup permissions once running (with the moodle configuration inside):

  chmod -R 777 /var/www/html #yolo

```
### ./mosh

```
 Description:
 Mosh = SSH + mobile connection

 Running:

 To normally use it:
 docker run -it --rm \
   -e TERM=xterm-256color \
   -v $HOME/.ssh:/root/.ssh \
   cdrage/mosh user@blahblahserver

 How I use it (since I pipe it through a VPN):
 docker run -it --rm \
   --net=container:vpn
   -e TERM=xterm-256color \
   -v $HOME/.ssh:/root/.ssh \
   cdrage/mosh user@blahblahserver

```
### ./mutt-gmail

```
 Description:

 My mutt configuration in a docker container

 Special thanks to jfrazelle for this config

 Running:

 docker run -it --rm \
    -e TERM=xterm-256color \
    -e MUTT_NAME \
    -e MUTT_EMAIL \
    -e MUTT_PASS \
    -e MUTT_PGP_KEY \
    -v $HOME/.gnupg:/home/user/.gnupg \
    -v $HOME/dropbox/etc/signature:/home/user/.mutt/signature \
    -v $HOME/dropbox/etc/aliases:/home/user/.mutt/aliases \
    -v /etc/localtime:/etc/localtime:ro \
    cdrage/mutt-gmail

```
### ./netflix-dnsmasq

```
 Description:

 This is used to create a DNS cacher/forwarder in order to
 spoof the location when accessing Netflix. Similar to how a
 VPN does it, but this is with DNS.

 IP is the IP of the sniproxy / haproxy server
 if you're running it on the same host, it's your ip (eth0 or whatever).

 WARNING: it's a *really* bad idea to run an open recurse DNS server 
 (prone to DNS DDoS aplification attacks), it's suggested to have some 
 form of IP firewall for this. (hint: just use iptables)

 Running:

 docker run \
   -p 53:53/udp \
   -e IP=10.10.10.1 \
   --name dnsmasq
   -d \
   cdrage/dnsmasq \

```
### ./netflix-sniproxy

```
 Description:

 DNS proxy (netflix unblocker) open source. Used in conjuction
 with netflix-dnsmasq :)
 fork of: https://github.com/trick77/dockerflix

 build Dockerfile.uk for uk version

 Running:

 docker run \
   -d \
   -p 80:80 \
   -p 443:443 \
   --name sniproxy \
   cdrage/sniproxy

```
### ./openvpn-client

```
 Description:

 An openvpn-client in an Alpine Linux container

 go check your public ip online and you'll see you're connected to the VPN :)

 Running:

 docker run -it 
 -v /filesblahblah/hacktheplanet.ovpn:/etc/openvpn/hacktheplanet.ovpn \
 --net=host --device /dev/net/tun:/dev/net/tun --cap-add=NET_ADMIN \
 cdrage/openvpn-client hacktheplanet.ovpn

```
### ./openvpn-client-docker

```
 Description:

 OpenVPN within an Ubuntu container

 Run then ctrl+p + ctrl+q after authenticating (this exists the container)
 
 Then from another container just use --net=container:openvpn
 
 remember to add 
  up /etc/openvpn/update-resolv-conf
  down /etc/openvpn/update-resolv-conf

  to your openvpn conf file!

 Running:

 docker run \
   --cap-add=NET_ADMIN \
   --device /dev/net/tun \
   -h openvpn \
   --name openvpn \
   -it \
   cdrage/openvpn-client-docker

```
### ./openvpn-server

```
 Description:

 original: https://github.com/jpetazzo/dockvpn

 NOTE:
 The keys are generate on EACH reboot and the private key is used in both the server
 and the client for simplicity reasons. If someone obtains your client information, they will be able 
 to access the server and perhaps spoof a session. It's recommended that you find an alternative way
 of deploying a VPN server if you are keen to have 100% security.

 If you wish to re-generate the certificates, simply restart your Docker container.

 Running:

 Start the openvpn server:
 docker run -d --privileged -p 1194:1194/udp -p 443:443/tcp --name vpn cdrage/openvpn-server

 Create a http server to termporarily download the configuration:
 docker run --rm -ti -p 8080:8080 --volumes-from vpn cdrage/openvpn-server serveconfig

 Download the configuration for your client to use:
 wget https://IP:8080/ --no-check-certificate -O config.ovpn

```
### ./peerflix

```
 Description:

 Stream from a magnet torrent
 
 Running:

 docker run -it -p 8888:8888 cdrage/peerflix $MAGNET_URL

 Then open up VLC and use localhost:8888 to view

```
### ./powerdns

```

```
### ./sensu-client

```
 Description:

 Original Source: https://github.com/arypurnomoz/sensu-client.docker

 This container allows you to run sensu in a container (yay) although there are some caveats.

 This is a basic container with NO checks. This is enough to get you setup and connecting to the sensu master. However, in order to add checks you'd have to pass in a folder of plugins (if you wish to pass them as a volume) or add them HERE to the Dockerfile.

 In my example, I use the docker-api and docker folder since I'll be mounting a -v /checks folder containing a few plugins. This is all optional and you may modify it to your own will.

 You'll also have to modify the checks.json file on the sensu master server in order to make sure you are using the correct plugins in the respective folders.


 Running:

 docker run \
  -v /etc/sensu/ssl/cert.pem:/etc/sensu/ssl/cert.pem \
  -v /etc/sensu/ssl/key.pem:/etc/sensu/ssl/key.pem \
  -v /etc/sensu/plugins:/etc/sensu/plugins \
  -e CLIENT_NAME=sensu-client \
  -e CLIENT_ADDRESS=10.0.0.1 \
  -e RABBITMQ_HOST=rabbitmq.local \
  -e RABBITMQ_PORT=5671 \
  -e RABBITMQ_VHOST="/sensu" \
  -e RABBITMQ_USER=sensu \
  -e RABBITMQ_PASS=sensu \
  -e SUB=metrics,check \
  cdrage/sensu-client

 or use the Makefile provided.
 ex.
 make all SSL=/etc/sensu/ssl IP=10.10.10.1 NAME=sensu SUB=default RABBIT_HOST=10.10.10.10 RABBIT_USERNAME=sensu RABBIT_PASS=sensu

```
### ./ssh

```
 Description:

 SSH in a Docker container :)

```
### ./teamspeak

```
 Description:

 Praise Gaben! Teamspeak in a docker container :)

 Original *awesome* source: https://github.com/luzifer-docker/docker-teamspeak3

 
 All your files will be located within ~/ts (sqlite database, whitelist, etc.). 
 This is your persistent folder. This will containe your credentials, whitelist, etc. So keep it safe.
 If you ever want to upgrade your teamspeak server (dif version or hash), simply point the files to there again.
 To find out the admin key on initial boot. Use docker logs teamspeak

 Running:

 docker run \
   --name teamspeak \
   -d \
   -p 9987:9987/udp \
   -p 30033:30033/tcp \
   -v $HOME/ts:/teamspeak3 \
   cdrage/teamspeak

```
### ./transmission

```
 Description:

 source: https://github.com/dperson/transmission

 ENVIRO VARIABLES
 TRUSER - set username for transmission auth
 TRPASSWD - set password for transmission auth
 TIMEZONE - set zoneinfo timezone

 Running:

 docker run \
   --name transmission \
   -p 9091:9091 \
   -v /path/to/directory:/var/lib/transmission-daemon/downloads \
   -e TRUSER=admin \
   -e TRPASSWD=admin \
   -d \
   cdrage/transmission

```
### ./weechat

```
 Description:

 Weechat IRC!

 recommended to daemonize it and run in background for collection of logs, etc while idle, simply attach to container.  ctrl+p ctrl+q to quit

 port 40900 is used for weechat relay (if you decide to use it)

 run then docker attach weechat

 Running:

 docker run -it -d \
   -e TERM=xterm-256color \
   -v /etc/localtime:/etc/localtime:ro \
   --name weechat \
   -p 40900:40900 \
   cdrage/weechat

```
