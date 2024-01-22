# Containerfiles

```
           +--------------+
          /|             /|
         / |            / |
        *--+-----------*  |
        |  |           |  |
        |  |           |  |
        |  |           |  |
        |  +-----------+--+
        | /            | /
        |/             |/
        *--------------*
```


All the Containerfiles I use.

**Notes:**
  - Scroll down on how to run it.
  - Containers can be started by using simple variables. 
  - Each container is automatically built and pushed to https://hub.docker.com/r/cdrage/ on each commit.
  - You may also `git clone https://github.com/cdrage/containerfiles` and build it yourself (`podman build -t username/container .` or `docker build -t username/container`). 


**Descriptions:**
Below is a general overview (with instructions) on each Docker container I use. This is automatically generated from the comments that I have left in each `Containerfile`.## Table of Contents

- [centos7-systemd](#centos7-systemd)
- [chrome](#chrome)
- [couchpotato](#couchpotato)
- [ddns](#ddns)
- [digitalocean-dns](#digitalocean-dns)
- [dind-ssh-centos7](#dind-ssh-centos7)
- [gameserver](#gameserver)
- [hamsket](#hamsket)
- [helloworld](#helloworld)
- [hugo](#hugo)
- [jrl](#jrl)
- [matterhorn](#matterhorn)
- [mattermost-desktop](#mattermost-desktop)
- [moodle](#moodle)
- [mosh](#mosh)
- [mosh-centos7](#mosh-centos7)
- [mutt-gmail](#mutt-gmail)
- [netflix-dnsmasq](#netflix-dnsmasq)
- [netflix-sniproxy](#netflix-sniproxy)
- [nfs-server](#nfs-server)
- [openvpn-client](#openvpn-client)
- [openvpn-client-docker](#openvpn-client-docker)
- [openvpn-server](#openvpn-server)
- [palworld](#palworld)
- [peerflix](#peerflix)
- [powerdns](#powerdns)
- [rtsp2mjpg](#rtsp2mjpg)
- [samba](#samba)
- [seafile-client](#seafile-client)
- [seafile-server](#seafile-server)
- [sensu-client](#sensu-client)
- [ssh](#ssh)
- [teamspeak](#teamspeak)
- [transmission](#transmission)
- [weechat](#weechat)
- [zoneminder](#zoneminder)

## [centos7-systemd](/centos7-systemd/Containerfile)

 CentOS 7 Systemd base file. Here be dragons.

## [chrome](/chrome/Containerfile)

 **Description:**

 Run Chrome in a container (thx jess)

 **Note:** Disabled sandbox due to running-in-a-container issue with userns 
 enabled in kernel, see: https://github.com/jfrazelle/dockerfiles/issues/149

 **Running:**

 ```sh
 podman run -d \
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

## [couchpotato](/couchpotato/Containerfile)

 **Description:**

 Couch Potato is a torrent grepper / downloader
 Pass in `-v ./couchpotato_config:/root/.couchpotato` for persistent data

 **Running:**

 ```sh
 podman run -d \
   -p 5050:5050 \
   --name couchpotato \
   cdrage/couchpotato 
 ```

 **Running with persistent data:**

 ```sh
 podman run -d \
   -p 5050:5050 \
   --name couchpotato \
   -v ./couchpotato_config:/root/.couchpotato \
   cdrage/couchpotato 
 ```

## [ddns](/ddns/Containerfile)

 **Description:**

 Dynamic DNS for DigitalOcean

 **Source**: https://github.com/gbolo/dockerfiles/tree/master/digitalocean-ddns

 **Running:**

 ```sh
 podman run \
 -d \
 --restart always \
 -e DODDNS_TOKEN=your_api_key \
 -e DODDNS_DOMAIN=your.domain.com \
 cdrage/ddns
 ```

## [digitalocean-dns](/digitalocean-dns/Containerfile)

 **Description:**

 **Source:** https://github.com/AMilassin/docker-dodns

 Docker to update DigitalOcean DNS similar to DynDNS.

 It's as easy as running the container and then editing the configuration file.
 
 **Running:**

 ```sh
 podman run \
  --name digitalocean-dns \
  -d \
  -v /var/digitalocean-dns:/config:rw \
  --restart=always \
  cdrage/digitalocean-dns
 ``` 

 **Configuration:**

 After running, open `/var/digitalocean-dns/dodns.conf.js` and edit it to your liking.

## [dind-ssh-centos7](/dind-ssh-centos7/Containerfile)

 Dockerfile to allow the ability to run docker-in-docker and an SSH server.
 See: https://github.com/docker-library/docs/tree/master/centos#systemd-integration
 Also: https://github.com/moby/moby/issues/35317

## [gameserver](/gameserver/Containerfile)

 **Description:**

 Very simple "steam server" container checker.
 
 Checks to see if there is a game server running on port 27015 LOCALLY (same IP as actual server)
 meant to be ran alongside the steam server container.
 
 **Running:**

 ```sh
 docker run -d \
    --name gameserver \
    -p 3000:3000
 ```

## [hamsket](/hamsket/Containerfile)

 **Description:**

 Run Hamsket in a container (multi-app chat tool)

 **Running:**

 ```sh
 podman run -d \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -e DISPLAY=unix$DISPLAY \
  -v /dev/shm:/dev/shm \
  --device /dev/dri \
  --name hamsket \
  cdrage/hamsket
 ```

## [helloworld](/helloworld/Containerfile)



## [hugo](/hugo/Containerfile)

 **Description:**
 My Hugo file for hosting my personal wiki / journal / etc.

## [jrl](/jrl/Containerfile)

 **Description:**

 Encrypted journal (for writing your life entries!, not logs!)

 In my case, I enter a timestamp each time I open the file and switch to vim insert mode.
 
 Pass in your encrypted txt file and type in your password.
 It'll then open it up in vim for you to edit and type up your
 latest entry.

 Remember, this is aes-256-cbc, so it's like hammering a nail
 with a screwdriver: 
 http://stackoverflow.com/questions/16056135/how-to-use-openssl-to-encrypt-decrypt-files

 Public / Private key would be better, but hell, this is just a text file.

 **First, encrypt a text file:**

 openssl aes-256-cbc -a -md md5 -salt -in foobar.txt -out foobar.enc
 
 Now run it!

 **Running:**

 ```sh
 podman run -it --rm \
   -v ~/txt.enc:/tmp/txt.enc \
   -v /etc/localtime:/etc/localtime:ro \
   cdrage/jrl
 ```
 
 This will ask for your password, decrypt it to a tmp folder and open it in vim.
 Once you :wq the file, it'll save.

## [matterhorn](/matterhorn/Containerfile)

 **Description:**

 A terminal interface for Mattermost via the client Matterhorn
 https://github.com/matterhorn-chat/matterhorn

 To run, simply supply a username, hostname and (additionally) a port number.
 For example:
 
 **Running:**

 ```sh
 podman run -it --rm \
  -v /etc/localtime:/etc/localtime \
  -e MM_USER=foobar@domain.com \
  -e MM_PASS=foobar \
  -e MM_HOST=gitlab.mattermost.com \
  -e MM_PORT=443 \
  --name matterhorn \
  cdrage/matterhorn
 ```

## [mattermost-desktop](/mattermost-desktop/Containerfile)

 **Description:**

 **Source:** https://github.com/treemo/docker-mattermost-desktop/blob/master/Dockerfile

 **Running:**

 ```sh
 podman run \
    -d \
    -e DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v $HOME/.config/Mattermost:/home/user/.config/Mattermost \
    --name mattermost-desktop \
    cdrage/mattermost-desktop
 ```

## [moodle](/moodle/Containerfile)

  **Description:**

  **Source:** https://github.com/playlyfe/docker-moodle

  **Setup:**

  First, grab moodle and extract.

  ```sh
  wget https://github.com/moodle/moodle/archive/v3.0.0.tar.gz
  tar -xvf v3.0.0.tar.gz
  mkdir /var/www
  mv moodle-3.0.0 /var/www/html
  ```
  

  TODO: SSL stuffs

  **Running:**

 ```sh
  podman run -d \
   -p 80:80 \
   -p 443:443 \
   -p 3306:3306 \
   -v /var/www/html:/var/www/html \
   --name moodle \
   moodle
 ```

  **Setup after running:**

  Setup permissions once running (with the moodle configuration inside):

  Head over to localhost:80 and proceed through the installation (remember to create the config.php file too during install!)

  ```sh
  MySQL username: moodleuser
  password: moodle
  ```

  All other values default :)

  chmod -R 777 /var/www/html #yolo

## [mosh](/mosh/Containerfile)

 **Description:**
 Mosh = SSH + mobile connection

 **Running:**

 To normally use it:
 ```sh
 podman run -it --rm \
   -e TERM=xterm-256color \
   -v $HOME/.ssh:/root/.ssh \
   cdrage/mosh user@blahblahserver
 ```

 How I use it (since I pipe it through a VPN):
 ```sh
 podman run -it --rm \
   --net=container:vpn
   -e TERM=xterm-256color \
   -v $HOME/.ssh:/root/.ssh \
   cdrage/mosh user@blahblahserver
 ```

## [mosh-centos7](/mosh-centos7/Containerfile)

 **Description:**
 Mosh = SSH + mobile connection

 **Running:**

 To normally use it:
 ```sh
 podman run -it --rm \
   -e TERM=xterm-256color \
   -v $HOME/.ssh:/root/.ssh \
   cdrage/mosh user@blahblahserver
 ```

 How I use it (since I pipe it through a VPN):
 ```sh
 podman run -it --rm \
   --net=container:vpn
   -e TERM=xterm-256color \
   -v $HOME/.ssh:/root/.ssh \
   cdrage/mosh user@blahblahserver
 ```

## [mutt-gmail](/mutt-gmail/Containerfile)

 **Description:**

 My mutt configuration in a docker container

 **Running:**

 ```sh
 podman run -it --rm \
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

## [netflix-dnsmasq](/netflix-dnsmasq/Containerfile)

 **Description:**

 This is used to create a DNS cacher/forwarder in order to
 spoof the location when accessing Netflix. Similar to how a
 VPN does it, but this is with DNS.

 IP is the IP of the sniproxy / haproxy server
 if you're running it on the same host, it's your ip (eth0 or whatever).

 WARNING: it's a *really* bad idea to run an open recurse DNS server 
 (prone to DNS DDoS aplification attacks), it's suggested to have some 
 form of IP firewall for this. (hint: just use iptables)

 **Running:**

 ```sh
 podman run \
   -p 53:53/udp \
   -e IP=10.10.10.1 \
   --name dnsmasq
   -d \
   cdrage/dnsmasq
 ```

## [netflix-sniproxy](/netflix-sniproxy/Containerfile)

 **Description:**

 **Source:** https://github.com/trick77/dockerflix

 DNS proxy (netflix unblocker) open source. Used in conjuction
 with netflix-dnsmasq :)

 build Dockerfile.uk for uk version

 **Running:**

 ```sh
 podman run \
   -d \
   -p 80:80 \
   -p 443:443 \
   --name sniproxy \
   cdrage/sniproxy
 ```

## [nfs-server](/nfs-server/Containerfile)

 **Description:**
 
 **Source:** https://github.com/sjiveson/nfs-server-alpine
 
 An NFS server (I use this to host volumes for Kubernetes deployments). Simple, deployed over 2049 TCP, NFSv4 on Alpine Linux.

 **Running:**
 
 ```sh
 podman run \
   -d \
   --restart=always \
   --net=host \
   --name nfs \
   --privileged \
   -v /var/nfs:/nfsshare \
   -e SHARED_DIRECTORY=/nfsshare \
   cdrage/nfs-server-alpine
 ```

 **Using:**

 ```sh
 # This should work
 sudo mount -v <IP>:/ /media/mountpoint

 # But do this if not
 sudo mount -v -o vers=4 <IP>:/ /media/mountpoint
 ```

## [openvpn-client](/openvpn-client/Containerfile)

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

## [openvpn-client-docker](/openvpn-client-docker/Containerfile)

 **Description:**

 OpenVPN within an Ubuntu container

 Run then ctrl+p + ctrl+q after authenticating (this exists the container)
 
 Then from another container just use `--net=container:openvpn`
 
 Remember to add 

 ```
  up /etc/openvpn/update-resolv-conf
  down /etc/openvpn/update-resolv-conf
 ```

 to your `openvpn.conf` file!

 **Running:**

 ```sh
 podman run \
   --cap-add=NET_ADMIN \
   --device /dev/net/tun \
   -h openvpn \
   --name openvpn \
   -it \
   cdrage/openvpn-client-docker
   ```

## [openvpn-server](/openvpn-server/Containerfile)

 **Description:**

 **Source:** https://github.com/jpetazzo/dockvpn

 NOTE:
 The keys are generate on EACH reboot and the private key is used in both the server
 and the client for simplicity reasons. If someone obtains your client information, they will be able 
 to access the server and perhaps spoof a session. It's recommended that you find an alternative way
 of deploying a VPN server if you are keen to have 100% security.

 If you wish to re-generate the certificates, simply restart your Docker container.

 **Running:**

 Start the openvpn server:
 ```sh
 podman run -d --privileged -p 1194:1194/udp -p 443:443/tcp --name vpn cdrage/openvpn-server
 ```

 Create a http server to termporarily download the configuration:
 ```sh
 podman run --rm -ti -p 8080:8080 --volumes-from vpn cdrage/openvpn-server serveconfig
 ```

 Download the configuration for your client to use:
 ```sh
 wget https://IP:8080/ --no-check-certificate -O config.ovpn
 ```

## [palworld](/palworld/Containerfile)

 **Description:**

 Originally from: https://github.com/thijsvanloef/palworld-server-docker
 
 Used to run the "palworld" game
 
 **Running:**

 ```sh
 docker run -d \
    --name palworld\
    -p 8211:8211 \
    -p 8221:8221 \
    -p 27015:27015 \
    -v <palworld-folder>:/palworld/ \
    -e PLAYERS=16 \
    -e PORT=8211 \
    -e MULTITHREADING=true \
    -e PUBLIC_IP="" \
    -e PUBLIC_PORT="" \
    -e COMMUNITY=true \
    -e SERVER_NAME="My Palworld Server" \
    -e SERVER_PASSWORD="supersecret" \
    -e ADMIN_PASSWORD="supersecret" \
    -e UPDATE_ON_BOOT=true \
    --restart unless-stopped \
    thijsvanloef/palworld-server-docker
 ```

## [peerflix](/peerflix/Containerfile)

 **Description:**

 Stream from a magnet torrent
 
 **Running:**

 ```sh
 podman run -it -p 8888:8888 cdrage/peerflix $MAGNET_URL
 ```

 Then open up VLC and use localhost:8888 to view

## [powerdns](/powerdns/Containerfile)

 Notes: TODO

## [rtsp2mjpg](/rtsp2mjpg/Containerfile)

 **Description:**

 Original source: https://github.com/eroji/rtsp2mjpg

 I use this for my WyzeCam to convert to ffmpeg so that OctoPrint can use it

 **Running:**

 ```sh
 podman run -d \
   -p 8090:8090 \
   -v /etc/localtime:/etc/localtime:ro \
   -e RTSP_URL=rtsp://admin:foobar@192.168.1.36/live \
   -e FFMPEG_INPUT_OPTS="-nostats -use_wallclock_as_timestamps 1 -r 15 -thread_queue_size 2048 -probesize 50M -analyzeduration 100M" \
   -e FFMPEG_OUTPUT_OPTS="-vf fps=15 -video_track_timescale 90000 -c:v h264_omx" \
   --restart always \
   --name rtsp2mjpg \
   cdrage/rtsp2mjpg
 ```

 **How to use:**

 Access at http://<ip>:8090/live.mjpg and /still.jpg

## [samba](/samba/Containerfile)

 **Description:** 
 
 **Source:** https://github.com/dperson/samba
 
 Samba in a Docker container (why? why not.)
 
 **Running:**

 (how I use it at least)

 ```sh
 podman run \
  -it \
  --name samba \
  -p 139:139 \
  -p 445:445 \
  -p 137:137/udp \
  -p 138:138/udp \
  -d \
  --network host \
  -v /var/samba:/mount \
  --restart=always \
  dperson/samba \
  -u "admin;password" \
  -s "backup;/mount/backup;yes;no;no;admin" \
  -w "WORKGROUP" \
  -n  
 ``` 

## [seafile-client](/seafile-client/Containerfile)

 **Description:**

 **Source:** https://bitbucket.org/xcgd-team/seafile-client

 After a lot of frustation, I've taken the solution from: https://bitbucket.org/xcgd-team/seafile-client
 and fiddled around with it for my needs.

 **Running:**

 ```sh
 mkdir ~/seafile

 podman run \
 -d \
 --name seafile-client \
 -v ~/seafile:/data \
 --restart=always \
 cdrage/seafile-client
 ```

 The seaf-cli is accessible via:

 ```sh
 docker exec seafile-client /usr/bin/seaf-cli
 ```

 In order to "add" a folder, you must sync it via the "sync" command line action

 ```sh
 # change "foobar" to your folder
 # mkdir must be created first in order to create proper permissions
 # Due to issues with python + passing in a password, you must
 # exec into the container to add your initial folder.
 mkdir -p ~/seafile/foobar
 docker exec -it seafile-client bash
 /usr/bin/seaf-cli sync -l YOUR_LIBRARY_ID -s YOUR_SEAFILE_SERVER -d /data/foobar -u YOUR_EMAIL -p YOUR_PASSWORD
 ```

 To check the status:

 ```sh
 docker exec -it seafile-client /usr/bin/seaf-cli status
 ```

## [seafile-server](/seafile-server/Containerfile)

 **Description:**

 **Source:** https://github.com/strator-dev/docker-seafile

 Okay, this Seafile Server container I've been using for a whileeeee and it's been *great*. But there are a few caveats you need to understand before deploying.

 First off, choose if you are going to use HTTP or HTTPS.

 Second, you need to make sure that SEAFILE_HOST is *actually* your domain name or a public IP address that will *NOT* change. If you set it to `0.0.0.0` you'll be able to access it and all, but come uploading/downloading files, it'll fall flat on it's face.

 **Environment variables:**

 | Variable               | Usage                                                                                                |
 |------------------------|------------------------------------------------------------------------------------------------------|
 | SEAFILE_VERSION        | Set the initial version of the Seafile Server. This will download and apply the current version set. |
 | SEAFILE_ADMIN_EMAIL    | Admin login email (this can be changed afteR)                                                        |
 | SEAFILE_ADMIN_PASSWORD | Admin password (this can be changed after)                                                           |
 | SEAFILE_HOST           | The public IP address / A record of the host                                                         |
 | SEAFILE_PORT           | Just use 8080 (fails on using 80 or 443 for some reason... too lazy to debug)                        |
 | SEAFILE_USE_HTTPS      | Set **1** to enable https and **0** to disable.                                                      | 

 **Running:**
 
 ```sh
 podman run \
 -d \
 -e "SEAFILE_VERSION=6.2.2" \
 -e "SEAFILE_ADMIN_EMAIL=root@root.com" \
 -e "SEAFILE_ADMIN_PASSWORD=YOURPASSWORD" \
 -e "SEAFILE_HOST=example.domain.com" \
 -e "SEAFILE_USE_HTTPS=1" \
 -e "SEAFILE_PORT=8080" \
 -v /var/seafile:/opt/seafile \
 -p 8080:8080 \
 --name="seafile" \
 cdrage/seafile-server
 ```

 **Using TLS / HTTPS:**

 Back-in-the-day Seafile used to use their own https / TLS setup, but it ended up being buggy, cumbersome, and constantly breaking. So now they simply ask for users to reverse proxy / throw an NGINX server in-front of Seafile.

 To do that, I've written a tutorial on how to use Let's Encrypt and nginx-proxy to create a TLS certificate in-front of a Docker Container: https://charliedrage.com/letsencrypt-on-docker

 Once you've set that up, it's as simple as doing:

 ```sh
 podman run \
 -d \
 -e "SEAFILE_VERSION=6.2.2" \
 -e "SEAFILE_ADMIN_EMAIL=root@root.com" \
 -e "SEAFILE_ADMIN_PASSWORD=YOURPASSWORD" \
 -e "SEAFILE_HOST=example.domain.com" \
 -e "SEAFILE_USE_HTTPS=1" \
 -e "SEAFILE_PORT=8080" \
 -e "VIRTUAL_HOST=example.com.com" \
 -e "VIRTUAL_PORT="8080" \
 -v /var/seafile:/opt/seafile \
 -p 8080:8080 \
 --name="seafile" \
 cdrage/seafile-server
 ```

 **Problems uploading files?**

 So I used https://github.com/jwilder/nginx-proxy for creating a reverse proxy in-front of the container. Big problem is that by default, there is a 100MB client_max_body_size in-front of the nginx proxy. Make sure that THIS has been added to nginx-proxy:

 ```sh
 client_max_body_size    0;
 proxy_connect_timeout   36000s;
 proxy_read_timeout      36000s;
 proxy_request_buffering off;
 ```

 **Other documentation**
 There's some more documentation that I will add later, but this is based upon a source image. See: https://github.com/strator-dev/docker-seafile for more details on how to run the garbage collector, etc.

## [sensu-client](/sensu-client/Containerfile)

 **Description:**

 **Source:** https://github.com/arypurnomoz/sensu-client.docker

 This container allows you to run sensu in a container (yay) although there are some caveats.

 This is a basic container with NO checks. This is enough to get you setup and connecting to the sensu master. However, in order to add checks you'd have to pass in a folder of plugins (if you wish to pass them as a volume) or add them HERE to the Dockerfile.

 In my example, I use the docker-api and docker folder since I'll be mounting a -v /checks folder containing a few plugins. This is all optional and you may modify it to your own will.

 You'll also have to modify the checks.json file on the sensu master server in order to make sure you are using the correct plugins in the respective folders.


 **Running:**

 ```sh
 podman run \
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
 ```

 or use the Makefile provided.
 ex.

 ```sh
 make all SSL=/etc/sensu/ssl IP=10.10.10.1 NAME=sensu SUB=default RABBIT_HOST=10.10.10.10 RABBIT_USERNAME=sensu RABBIT_PASS=sensu
 ```

## [ssh](/ssh/Containerfile)

 **Description:**
 SSH in a Docker container :)

 **Running:**

 To normally use it:
 ```sh
 podman run -it --rm \
   -e TERM=xterm-256color \
   -v $HOME/.ssh:/root/.ssh \
   cdrage/ssh user@blahblahserver
 ```

 How I use it (since I pipe it through a VPN):
 ```sh
 podman run -it --rm \
   --net=container:vpn
   -e TERM=xterm-256color \
   -v $HOME/.ssh:/root/.ssh \
   cdrage/ssh user@blahblahserver
 ```

## [teamspeak](/teamspeak/Containerfile)

 **Description:**

 **Source:** https://github.com/luzifer-docker/docker-teamspeak3

 Praise Gaben! Teamspeak in a docker container :)

 All your files will be located within ~/ts (sqlite database, whitelist, etc.). 
 This is your persistent folder. This will containe your credentials, whitelist, etc. So keep it safe.
 If you ever want to upgrade your teamspeak server (dif version or hash), simply point the files to there again.
 To find out the admin key on initial boot. Use docker logs teamspeak

 **Running:**

 ```sh
 podman run \
   --name teamspeak \
   -d \
   -p 9987:9987/udp \
   -p 30033:30033/tcp \
   -v $HOME/ts:/teamspeak3 \
   cdrage/teamspeak
 ```

## [transmission](/transmission/Containerfile)

 **Description:**

 *Source:** https://github.com/dperson/transmission
 
 ```
 ENV VARIABLES
 TRUSER - set username for transmission auth
 TRPASSWD - set password for transmission auth
 TIMEZONE - set zoneinfo timezone
 ```

 **Running:**

 ```sh
 podman run \
   --name transmission \
   -p 9091:9091 \
   -v ~/Downloads:/var/lib/transmission-daemon/downloads \
   -e TRUSER=admin \
   -e TRPASSWD=admin \
   -d \
   cdrage/transmission
 ```

## [weechat](/weechat/Containerfile)

 **Description:**

 Weechat IRC!

 recommended to daemonize it and run in background for collection of logs, etc while idle, simply attach to container.  ctrl+p ctrl+q to quit

 port 40900 is used for weechat relay (if you decide to use it)

 run then `docker attach weechat`

 **Running:**

 ```sh
 podman run -it -d \
   -e TERM=xterm-256color \
   -v /etc/localtime:/etc/localtime:ro \
   --name weechat \
   -p 40900:40900 \
   cdrage/weechat
 ```

## [zoneminder](/zoneminder/Containerfile)

 **Description:**

 Source: https://github.com/dlandon/zoneminder

 Run zoneminder in a container.

 Zoneminder GUI: http://IP:8080/zm or https://IP:8443/zm

 zmNinja Notification Sever: https://IP:9000

 **Running:**

 ```sh
 podman run -d --name zoneminder \
 --net bridge \
  --privileged \
  -p 8080:80/tcp \
  -p 8443:443/tcp \
  -p 9000:9000/tcp \
  -e TZ="America/New_York" \
  -e SHMEM="50%" \
  -e PUID="99" \
  -e PGID="100" \
  -v ~/zm/config:/config \
  -v ~/zm/data:/var/cache/zoneminder \
  cdrage/zoneminder
 ```

