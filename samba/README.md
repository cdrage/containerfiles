 **Description:** 
 
 **Source:** https://github.com/dperson/samba
 
 Samba in a Docker container (why? why not.)
 
 **Running:**

 (how I use it at least)

 ```sh
 podman run \
  -it \
  --name samba \
  -p 139:139 \
  -p 445:445 \
  -p 137:137/udp \
  -p 138:138/udp \
  -d \
  --network host \
  -v /var/samba:/mount \
  --restart=always \
  dperson/samba \
  -u "admin;password" \
  -s "backup;/mount/backup;yes;no;no;admin" \
  -w "WORKGROUP" \
  -n  
 ``` 
