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
