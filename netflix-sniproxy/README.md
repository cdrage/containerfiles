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
