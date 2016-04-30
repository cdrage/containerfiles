Git repo for my personal Dockerfiles. README.md is auto-generated from Dockerfile comments
### ./chrome

```
 Run Chrome in a container (thx jess)

  docker run -d \
    --net=container:vpn \
    --memory 3gb \
    -v /etc/localtime:/etc/localtime:ro \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e DISPLAY=unix$DISPLAY \
    -v $HOME/.chrome:/data \
    -v $HOME/docker_files/chrome_downloads:/root/Downloads \
    -v /dev/shm:/dev/shm \
    --device /dev/dri \
    --name chrome \
    $USER/chrome --no-sandbox --user-data-dir=/data --test-type

    no sandbox due to issue atm

```
### ./consul

```
 source: github.com/jfrazelle/dockerfiles
 THANKS YO

 to run:
 
 docker run -d \
  --restart always \
  -v $HOME/.consul:/etc/consul.d \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --net host \
  -e GOMAXPROCS=2 \
  --name consul \
  $USER/consul \
  agent \
  -bootstrap-expect 1 \
  -config-dir /etc/consul.d \
  -data-dir /data \
  -encrypt $(docker run --rm $USER/consul keygen) \
  -ui-dir /usr/src/consul \
  -server \
  -dc dc1 \
  -bind 0.0.0.0

```
### ./couchpotato

```
 docker run -d -p 5050:5050 --name couchpotato couchpotato

```
### ./dropbox

```
 docker run -d -e UID=$(id -u) -v ~/.dropbox:/home/.dropbox -v ~/dropbox:/home/Dropbox --name dropbox $USER/dropbox

```
### ./glances

```
 Run glances in a container
 SOURCE: https://github.com/nicolargo/glances

 docker run --rm -it \
	--pid host \
	--ipc host \
	--net host \
	--name glances \
	charliedrage/glances

```
### ./graphite

```
RUN echo deb http://archive.ubuntu.com/ubuntu $(lsb_release -cs) main universe > /etc/apt/sources.list.d/universe.list
 dependencies
 python dependencies
 install graphite
 install whisper
 install carbon
 install statsd
 config nginx
 init django admin
 logging support
 daemons
 default conf setup
 cleanup
 defaults

```
### ./jekyll

```
 docker run --label=jekyll --volume=$(pwd):/srv/jekyll -d -p 80:4000 --restart=always jekyll/jekyll jekyll s

```
### ./jrl

```
 Encrypted journal (for writing your life entries!, not logs!)
 
 Pass in your encrypted txt file and type in your password.
 It'll then open it up in vim for you to edit and type up your
 latest entry.

 Remember, this is aes-256-cbc, so it's like hammering a nail
 with a screwdriver: 
 http://stackoverflow.com/questions/16056135/how-to-use-openssl-to-encrypt-decrypt-files

 Public / Private key would be better, but hell, this is just a txt file.
 
 Now run it!

 docker run -it --rm -v ~/txt.enc:/tmp/txt.enc -v /etc/localtime:/etc/localtime:ro $USER/jrl

```
### ./kubernetes

```

```
### ./libvirtd

```
 YAY! Libvirtd within Docker! USE DAT KVM VIRTUALIZATION
 Although this doesn't work very well at the moment (see KVM module errors)

 docker run
 --privileged \
 --net=host
 -p 16509:16509
 -v /var/lib/libvirt:/var/lib/libvirt
 --name libvirtd libvirtd

 to connect (on client): virsh --connect qemu+tcp://localhost/system

```
### ./line

```
 You'll have to get LINE.exe first from somewhere ;)
 docker run --rm -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=unix$DISPLAY -H localhost charliedrage/line

```
### ./moodle

```
  source: https://github.com/playlyfe/docker-moodle

  First, grab moodle and extract.
  wget https://github.com/moodle/moodle/archive/v3.0.0.tar.gz
  tar -xvf v3.0.0.tar.gz
  mkdir /var/www
  mv moodle-3.0.0 /var/www/html
  
  Now let's build the docker container
  docker build -t moodle .
  docker run -d --name moodle -p 80:80 -p 443:443 -p 3306:3306 -v /var/www/html:/var/www/html moodle

  Permission dat shit
  chmod -R 777 /var/www/html

  Head over to localhost:80 and proceed through the installation (remember to create the config.php file too during install!)

  MySQL username: moodleuser
  password: moodle

  All other values default :)

  TODO: SSL stuffs

```
### ./mosh

```
 
 docker run -it --rm \
 -e TERM=xterm-256color \
 -v $HOME/.ssh:/root/.ssh \
 $USER/mosh user@blahblahserver

 how i use it:
 docker run -it --rm \
 --net=container:vpn
 -e TERM=xterm-256color \
 -v $HOME/.ssh:/root/.ssh \
 $USER/mosh user@blahblahserver
 

```
### ./mutt-gmail

```
 special thanks to jfrazelle for this config
  docker run -it --rm \
    -e TERM=xterm-256color \
    -e MUTT_NAME \
    -e MUTT_EMAIL \
    -e MUTT_PASS \
    -v $HOME/.gnupg:/home/user/.gnupg \
    -v $HOME/dropbox/etc/signature:/home/user/.mutt/signature \
    -v $HOME/dropbox/etc/aliases:/home/user/.mutt/aliases \
    -v /etc/localtime:/etc/localtime:ro \
    charliedrage/mutt
 copy over files
 vim settings

```
### ./netflix-dnsmasq

```
 DNS cacher/forwarder
 Set IP as the forwarder :)
 docker run -p 53:53/udp -e IP=10.10.10.1 -d dnsmasq --name dnsmasq
 IP is the IP of the sniproxy / haproxy server
 if you're running it on the same host, it's your ip (eth0 or whatever)

 WARNING: it's a *really* bad idea to run an open recurse DNS server 
 (prone to DNS DDoS aplification attacks), it's suggested to have some 
 form of IP firewall for this. (hint: just use iptables)

```
### ./netflix-sniproxy

```
 DNS proxy (netflix unblocker) open source.
 fork of: https://github.com/trick77/dockerflix

 docker run -d -p 80:80 -p 443:443 --name sniproxy sniproxy

 build Dockerfile.uk for uk version

```
### ./nmap

```
 Original source: github.com/pandrew/dockerfiles
 build it yo:
 docker build -t nmap .

 and run it!
 docker run --rm -it --net=host --cap-add=NET_ADMIN nmap

 ex.
 docker run --rm -it --net=host --cap-add=NET_ADMIN nmap -v scanme.nmap.org

```
### ./nomad

```
 Nomad from Hashicorp. github.com/hashicorp/nomad

 To build the Nomad binary:
 git clone https://github.com/hashicorp/nomad
 cd nomad && make bin

 To use:
 docker run \
 --net=host \
 -v /run/docker.sock:/run/docker.sock \
 --name nomad \
 -p 4646:4646 \
 -p 4647:4647 \
 -p 4648:4648 \
 nomad agent -dev -network-interface YOURINTERFACE(eth0 probably)

 Now simply bash into it. Run ./nomad init && ./nomad run example.nomad
 and you'll see a redis container spring up on your host :)

```
### ./openvpn-client

```
 An openvpn-client in a container

 docker run -it 
 -v /filesblahblah/hacktheplanet.ovpn:/etc/openvpn/hacktheplanet.ovpn \
 --net=host --device /dev/net/tun:/dev/net/tun --cap-add=NET_ADMIN \
 openvpn-client hacktheplanet.ovpn

 go check your public ip online and you'll see you're connected to the VPN :)

```
### ./openvpn-client-docker

```
 
 docker run --cap-add=NET_ADMIN --device /dev/net/tun -h openvpn --name openvpn -it openvpn
 
 then from another container just use --net=container:openvpn
 
 remember to add 
  up /etc/openvpn/update-resolv-conf
  down /etc/openvpn/update-resolv-conf

  to your openvpn conf file!

```
### ./openvpn-server

```
 original: https://github.com/jpetazzo/dockvpn
 
 Start the openvpn server:
 SERVER=$(docker run -d --privileged -p 1194:1194/udp -p 443:443/tcp $USER/openvpn)

 Create a http server to termporarily download the configuration:
 docker run --rm -ti -p 8080:8080 --volumes-from $SERVER $USER/openvpn serveconfig

 Download the configuration for your client to use:
 wget https://IP:8080/ --no-check-certificate -O config.ovpn

```
### ./peerflix

```
 docker run -it -p 8888:8888 wikus/peerflix "magnet shit:"

```
### ./plex

```
 source https://github.com/wernight/docker-plex-media-server
 mkdir ~/plex-config
 chown 797:797 -R ~/plex-config
 docker run -d -v /root/plex-config:/config -v /data:/media -p 32400:32400 --net=host --name plex plex

 Note:
 If you are using this on a remote server (VPS and such), you must edit Preferences.xml within the plex-config 
 folder and add your network within <Preferences> allowedNetworks="192.168.1.0/255.255.255.0" if you wish
 to set this up remotely

 Or you can simply SSH portforward to the server to configure everything

```
### ./samba

```
 source: https://github.com/JensErat/docker-samba-publicshare
 docker run -d  -p 445:445 -p 137:137 -p 138:138 -p 139:139 -v /data:/data --env workgroup=workgroup samba

```
### ./sensu-client

```
 Original Source: https://github.com/arypurnomoz/sensu-client.docker

 This container allows you to run sensu in a container (yay) although there are some caveats.

 This is a basic container with NO checks. This is enough to get you setup and connecting to the sensu master. However, in order to add checks you'd have to pass in a folder of plugins (if you wish to pass them as a volume) or add them HERE to the Dockerfile.

 In my example, I use the docker-api and docker folder since I'll be mounting a -v /checks folder containing a few plugins. This is all optional and you may modify it to your own will.

 You'll also have to modify the checks.json file on the sensu master server in order to make sure you are using the correct plugins in the respective folders.

 docker run \
  -v ~/cert.pem:/etc/sensu/ssl/cert.pem \
  -v ~/key.pem:/etc/sensu/ssl/key.pem \
  -v ~/plugins:/etc/sensu/plugins \
  -e CLIENT_NAME=sensu-client \
  -e CLIENT_ADDRESS=10.0.0.1 \
  -e RABBITMQ_HOST=rabbitmq.local \
  -e RABBITMQ_PORT=5671 \
  -e RABBITMQ_VHOST="/sensu" \
  -e RABBITMQ_USER=sensu \
  -e RABBITMQ_PASS=sensu \
  -e SUB=metrics,check \
  sensu-client

 or use the Makefile provided :)
 Install misc packages (in my case, checking the docker port, thus needing docker + docker-api :)

```
### ./ssh

```

```
### ./teamspeak

```
 Source: https://github.com/luzifer-docker/docker-teamspeak3

 To run:
 docker run --name ts3 -d -p 9987:9987/udp -p 30033:30033/tcp -v ~/ts3:/teamspeak3 $USER/ts3
 
 All your files will be located within ~/ts3 (sqlite database, whitelist, etc.). 
 This is your persistent folder, so rare pepe do not touch. 
 If you ever want to upgrade your teamspeak server (dif version or hash), simply point the files to there again.
 To find out the admin key, use docker logs

```
### ./tor

```

```
### ./tor-messenger

```
 Run tor messenger in a container

 docker run -d -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=unix$DISPLAY $USER/tor-messenger


```
### ./transmission

```
 source: https://github.com/dperson/transmission

 docker run --name transmission -p 9091:9091 -v /path/to/directory:/var/lib/transmission-daemon/downloads -e TRUSER=admin -e TRPASSWD=admin -d transmission

 ENVIRO VARIABLES
 TRUSER - set username for transmission auth
 TRPASSWD - set password for transmission auth
 TIMEZONE - set zoneinfo timezone

```
### ./weechat

```
 recommended to daemonize it and run in background for collection of logs, etc while idle, simply attach to container.  ctrl+p ctrl+q to quit

 docker run -it -d \
 -e TERM=xterm-256color \
 -v /etc/localtime:/etc/localtime:ro \
 --name weechat \
 -p 40900:40900 \
 weechat

 port 40900 is used for weechat relay (if you decide to use it)

 docker attach weechat

```
### ./wifikill

```
 DISCLAIMER: Only use this on YOUR OWN network. This script is not responsible for any damages it causes.
 This uses ARP spoofing: https://en.wikipedia.org/wiki/ARP_spoofing by sending a fake MAC address to the victim believing it to be the gateway. Thus kicking everyone else off.
 
 To use:
 docker run --rm -it --net=host --cap-add=NET_ADMIN wifikill 

```
### ./ykpersonalize

```
 Run ykpersonalize in a container (yubico key)

 source: https://github.com/jfrazelle/dockerfiles

 docker run --rm -it \
 	--device /dev/bus/usb \
 	--device /dev/usb
	--name ykpersonalize \
	$USER/ykpersonalize bash

```
