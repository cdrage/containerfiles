 **Description:**

 Run Hamsket in a container (multi-app chat tool)

 **Running:**

 ```sh
 docker run -d \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -e DISPLAY=unix$DISPLAY \
  -v /dev/shm:/dev/shm \
  --device /dev/dri \
  --name hamsket \
  cdrage/hamsket
 ```
