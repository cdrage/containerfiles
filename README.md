# Dockerfiles

```
                  ##         .
            ## ## ##        ==
         ## ## ## ## ##    ===
     /"""""""""""""""""\___/ ===
~~~ {~~ ~~~~ ~~~ ~~~~ ~~~ ~ /  ===- ~~~
     \______ o           __/
       \    \         __/
        \____\_______/
```

All the Dockerfiles I use! Read below for a description of the container you're about to use.

Each container is automatically built and pushed to [https://hub.docker.com/r/cdrage/](https://hub.docker.com/r/cdrage/) upon each commit.

You may also `git clone https://github.com/cdrage/dockerfiles` and build it yourself (`docker build -t username/container .`).

Below is a general overview (with instructions) on each Docker container I use. This is automatically generated from the comments that I have left in each `Dockerfile`.

Open an issue if there's a problem with a container!
## cdrage/chrome

 **Description:**

 Run Chrome in a container (thx jess)

 **Note:** Disabled sandbox due to running-in-a-container issue with userns 
 enabled in kernel, see: https://github.com/jfrazelle/dockerfiles/issues/149

 **Running:**

 ```sh
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

## cdrage/couchpotato

 **Description:**

 Couch Potato is a torrent grepper / downloader
 Pass in `-v ./couchpotato_config:/root/.couchpotato` for persistent data

 **Running:**

 ```sh
 docker run -d \
   -p 5050:5050 \
   --name couchpotato \
   cdrage/couchpotato 
 ```

 **Running with persistent data:**

 ```sh
 docker run -d \
   -p 5050:5050 \
   --name couchpotato \
   -v ./couchpotato_config:/root/.couchpotato \
   cdrage/couchpotato 
 ```


## cdrage/digitalocean-dns

 **Description:**

 **Source:** https://github.com/AMilassin/docker-dodns

 Docker to update DigitalOcean DNS similar to DynDNS.

 It's as easy as running the container and then editing the configuration file.
 
 **Running:**

 ```sh
 docker run \
  --name do \
  -d \
  -v ~/digitalocean:/config:rw \
  --restart=always \
  cdrage/digitalocean-dns
 ``` 

 **Configuration:**

 After running, open `~/digitalocean/dodns.conf.js` and edit it to your liking.

## cdrage/jrl

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
 docker run -it --rm \
   -v ~/txt.enc:/tmp/txt.enc \
   -v /etc/localtime:/etc/localtime:ro \
   cdrage/jrl
 ```
 
 This will ask for your password, decrypt it to a tmp folder and open it in vim.
 Once you :wq the file, it'll save.

## cdrage/matterhorn

 **Description:**

 A terminal interface for Mattermost via the client Matterhorn
 https://github.com/matterhorn-chat/matterhorn

 To run, simply supply a username, hostname and (additionally) a port number.
 For example:
 
 **Running:**

 ```sh
 docker run -it --rm \
  -e MM_USER=foobar@domain.com \
  -e MM_PASS=foobar \
  -e MM_HOST=gitlab.mattermost.com \
  -e MM_PORT=443 \
  --name matterhorn \
  cdrage/matterhorn
 ```

## cdrage/mattermost-desktop

 **Description:**

 **Source:** https://github.com/treemo/docker-mattermost-desktop/blob/master/Dockerfile

 **Running:**

 ```sh
 docker run \
    -d \
    -e DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v $HOME/.config/Mattermost:/home/user/.config/Mattermost \
    --name mattermost-desktop \
    cdrage/mattermost-desktop
 ```

## cdrage/moodle

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
  docker run -d \
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

## cdrage/mosh

 **Description:**
 Mosh = SSH + mobile connection

 **Running:**

 To normally use it:
 ```sh
 docker run -it --rm \
   -e TERM=xterm-256color \
   -v $HOME/.ssh:/root/.ssh \
   cdrage/mosh user@blahblahserver
 ```

 How I use it (since I pipe it through a VPN):
 ```sh
 docker run -it --rm \
   --net=container:vpn
   -e TERM=xterm-256color \
   -v $HOME/.ssh:/root/.ssh \
   cdrage/mosh user@blahblahserver
 ```

## cdrage/mutt-gmail

 **Description:**

 My mutt configuration in a docker container

 **Running:**

 ```sh
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

## cdrage/netflix-dnsmasq

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
 docker run \
   -p 53:53/udp \
   -e IP=10.10.10.1 \
   --name dnsmasq
   -d \
   cdrage/dnsmasq
 ```

## cdrage/netflix-sniproxy

 **Description:**

 **Source:** https://github.com/trick77/dockerflix

 DNS proxy (netflix unblocker) open source. Used in conjuction
 with netflix-dnsmasq :)

 build Dockerfile.uk for uk version

 **Running:**

 ```sh
 docker run \
   -d \
   -p 80:80 \
   -p 443:443 \
   --name sniproxy \
   cdrage/sniproxy
 ```

## cdrage/nfs-server

 **Description:**
 
 **Source:** https://github.com/sjiveson/nfs-server-alpine
 
 An NFS server (I use this to host volumes for Kubernetes deployments). Simple, deployed over 2049 TCP, NFSv4 on Alpine Linux.

 **Running:**
 
 ```sh
 docker run \
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

## cdrage/openvpn-client

 **Description:**

 An openvpn-client in an Alpine Linux container

 go check your public ip online and you'll see you're connected to the VPN :)

 **Running:**

 ```sh
 docker run -it 
 -v /filesblahblah/hacktheplanet.ovpn:/etc/openvpn/hacktheplanet.ovpn \
 --net=host --device /dev/net/tun:/dev/net/tun --cap-add=NET_ADMIN \
 cdrage/openvpn-client hacktheplanet.ovpn
 ```

## cdrage/openvpn-client-docker

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
 docker run \
   --cap-add=NET_ADMIN \
   --device /dev/net/tun \
   -h openvpn \
   --name openvpn \
   -it \
   cdrage/openvpn-client-docker
   ```

## cdrage/openvpn-server

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
 docker run -d --privileged -p 1194:1194/udp -p 443:443/tcp --name vpn cdrage/openvpn-server
 ```

 Create a http server to termporarily download the configuration:
 ```sh
 docker run --rm -ti -p 8080:8080 --volumes-from vpn cdrage/openvpn-server serveconfig
 ```

 Download the configuration for your client to use:
 ```sh
 wget https://IP:8080/ --no-check-certificate -O config.ovpn
 ```

## cdrage/peerflix

 **Description:**

 Stream from a magnet torrent
 
 **Running:**

 ```sh
 docker run -it -p 8888:8888 cdrage/peerflix $MAGNET_URL
 ```

 Then open up VLC and use localhost:8888 to view

## cdrage/powerdns

 Notes: TODO

## cdrage/samba

 **Description:** 
 
 **Source:** https://github.com/dperson/samba
 
 Samba in a Docker container (why? why not.)
 
 **Running:**

 (how I use it at least)

 ```sh
 docker run \
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

## cdrage/seafile-client

 **Description:**

 **Source:** https://bitbucket.org/xcgd-team/seafile-client

 After a lot of frustation, I've taken the solution from: https://bitbucket.org/xcgd-team/seafile-client
 and fiddled around with it for my needs.

 **Running:**

 ```sh
 mkdir ~/seafile

 docker run \
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

## cdrage/seafile-server

 **Description:**
 Seafile server

 **Source:** https://github.com/strator-dev/docker-seafile

 **Running:**

 ```sh
 docker run \
 -d \
 -e "SEAFILE_VERSION=6.2.2" \
 -e "SEAFILE_ADMIN_EMAIL=root@root.com" \
 -e "SEAFILE_ADMIN_PASSWORD=YOURPASSWORD" \
 -e "SEAFILE_HOST=0.0.0.0" \
 -e "SEAFILE_PORT=8080" \
 -v "/var/seafile:/opt/seafile" \
 -p 0.0.0.0:8080:8080 \
 --name="seafile" \
 cdrage/seafile-server
 ```

 TODO: Write more documentation
 See: https://github.com/strator-dev/docker-seafile for more details on how to run the garbage collector, etc.

## cdrage/sensu-client

 **Description:**

 **Source:** https://github.com/arypurnomoz/sensu-client.docker

 This container allows you to run sensu in a container (yay) although there are some caveats.

 This is a basic container with NO checks. This is enough to get you setup and connecting to the sensu master. However, in order to add checks you'd have to pass in a folder of plugins (if you wish to pass them as a volume) or add them HERE to the Dockerfile.

 In my example, I use the docker-api and docker folder since I'll be mounting a -v /checks folder containing a few plugins. This is all optional and you may modify it to your own will.

 You'll also have to modify the checks.json file on the sensu master server in order to make sure you are using the correct plugins in the respective folders.


 **Running:**

 ```sh
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
 ```

 or use the Makefile provided.
 ex.

 ```sh
 make all SSL=/etc/sensu/ssl IP=10.10.10.1 NAME=sensu SUB=default RABBIT_HOST=10.10.10.10 RABBIT_USERNAME=sensu RABBIT_PASS=sensu
 ```

## cdrage/ssh

 **Description:**
 SSH in a Docker container :)

 **Running:**

 To normally use it:
 ```sh
 docker run -it --rm \
   -e TERM=xterm-256color \
   -v $HOME/.ssh:/root/.ssh \
   cdrage/ssh user@blahblahserver
 ```

 How I use it (since I pipe it through a VPN):
 ```sh
 docker run -it --rm \
   --net=container:vpn
   -e TERM=xterm-256color \
   -v $HOME/.ssh:/root/.ssh \
   cdrage/ssh user@blahblahserver
 ```

## cdrage/teamspeak

 **Description:**

 **Source:** https://github.com/luzifer-docker/docker-teamspeak3

 Praise Gaben! Teamspeak in a docker container :)

 All your files will be located within ~/ts (sqlite database, whitelist, etc.). 
 This is your persistent folder. This will containe your credentials, whitelist, etc. So keep it safe.
 If you ever want to upgrade your teamspeak server (dif version or hash), simply point the files to there again.
 To find out the admin key on initial boot. Use docker logs teamspeak

 **Running:**

 ```sh
 docker run \
   --name teamspeak \
   -d \
   -p 9987:9987/udp \
   -p 30033:30033/tcp \
   -v $HOME/ts:/teamspeak3 \
   cdrage/teamspeak
 ```

## cdrage/transmission

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
 docker run \
   --name transmission \
   -p 9091:9091 \
   -v ~/Downloads:/var/lib/transmission-daemon/downloads \
   -e TRUSER=admin \
   -e TRPASSWD=admin \
   -d \
   cdrage/transmission
 ```

## cdrage/weechat

 **Description:**

 Weechat IRC!

 recommended to daemonize it and run in background for collection of logs, etc while idle, simply attach to container.  ctrl+p ctrl+q to quit

 port 40900 is used for weechat relay (if you decide to use it)

 run then `docker attach weechat`

 **Running:**

 ```sh
 docker run -it -d \
   -e TERM=xterm-256color \
   -v /etc/localtime:/etc/localtime:ro \
   --name weechat \
   -p 40900:40900 \
   cdrage/weechat
 ```

