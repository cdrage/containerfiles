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
