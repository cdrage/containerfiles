 **Description:**

 Weechat IRC!

 recommended to daemonize it and run in background for collection of logs, etc while idle, simply attach to container.  ctrl+p ctrl+q to quit

 port 40900 is used for weechat relay (if you decide to use it)

 run then `docker attach weechat`

 **Running:**

 ```sh
 podman run -it -d \
   -e TERM=xterm-256color \
   -v /etc/localtime:/etc/localtime:ro \
   --name weechat \
   -p 40900:40900 \
   cdrage/weechat
 ```
