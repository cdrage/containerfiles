 **Description:**
 Mosh = SSH + mobile connection

 **Running:**

 To normally use it:
 ```sh
 podman run -it --rm \
   -e TERM=xterm-256color \
   -v $HOME/.ssh:/root/.ssh \
   cdrage/mosh user@blahblahserver
 ```

 How I use it (since I pipe it through a VPN):
 ```sh
 podman run -it --rm \
   --net=container:vpn
   -e TERM=xterm-256color \
   -v $HOME/.ssh:/root/.ssh \
   cdrage/mosh user@blahblahserver
 ```
