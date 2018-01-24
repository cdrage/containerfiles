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
