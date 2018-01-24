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
