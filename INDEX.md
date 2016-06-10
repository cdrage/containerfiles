# List of *AWESOME* user-create Dockerfiles I (constantly) use and the commands to run them.


####chrome

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
