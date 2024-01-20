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
