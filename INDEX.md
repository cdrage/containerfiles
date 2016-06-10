# List of *AWESOME* user-create Dockerfiles I (constantly) use and the commands to run them.


#### chrome

https://github.com/jfrazelle

```
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

#### graphite

https://github.com/hopsoft/docker-graphite-statsd

#### plex

https://github.com/wernight/docker-plex-media-server

**Note:**

If you are using this on a remote server (VPS and such), you must edit Preferences.xml within the plex-config 
folder and add your network within <Preferences> allowedNetworks="192.168.1.0/255.255.255.0" if you wish
to set this up remotely

Or you can simply SSH portforward to the server to configure everything

```
mkdir ~/plex-config
chown 797:797 -R ~/plex-config
docker run -d -v /root/plex-config:/config -v /data:/media -p 32400:32400 --net=host --name plex plex
```

#### transmission


