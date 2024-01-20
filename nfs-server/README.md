 **Description:**
 
 **Source:** https://github.com/sjiveson/nfs-server-alpine
 
 An NFS server (I use this to host volumes for Kubernetes deployments). Simple, deployed over 2049 TCP, NFSv4 on Alpine Linux.

 **Running:**
 
 ```sh
 podman run \
   -d \
   --restart=always \
   --net=host \
   --name nfs \
   --privileged \
   -v /var/nfs:/nfsshare \
   -e SHARED_DIRECTORY=/nfsshare \
   cdrage/nfs-server-alpine
 ```

 **Using:**

 ```sh
 # This should work
 sudo mount -v <IP>:/ /media/mountpoint

 # But do this if not
 sudo mount -v -o vers=4 <IP>:/ /media/mountpoint
 ```
