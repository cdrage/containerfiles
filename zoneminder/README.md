 **Description:**

 Source: https://github.com/dlandon/zoneminder

 Run zoneminder in a container.

 Zoneminder GUI: http://IP:8080/zm or https://IP:8443/zm

 zmNinja Notification Sever: https://IP:9000

 **Running:**

 ```sh
 docker run -d --name zoneminder \
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
