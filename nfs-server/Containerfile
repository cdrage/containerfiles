# **Description:**
# 
# **Source:** https://github.com/sjiveson/nfs-server-alpine
# 
# An NFS server (I use this to host volumes for Kubernetes deployments). Simple, deployed over 2049 TCP, NFSv4 on Alpine Linux.
#
# **Running:**
# 
# ```sh
# docker run \
#   -d \
#   --restart=always \
#   --net=host \
#   --name nfs \
#   --privileged \
#   -v /var/nfs:/nfsshare \
#   -e SHARED_DIRECTORY=/nfsshare \
#   cdrage/nfs-server-alpine
# ```
#
# **Using:**
#
# ```sh
# # This should work
# sudo mount -v <IP>:/ /media/mountpoint
#
# # But do this if not
# sudo mount -v -o vers=4 <IP>:/ /media/mountpoint
# ```

FROM alpine:latest
LABEL maintainer "Steven Iveson <steve@iveson.eu>"
LABEL source "https://github.com/sjiveson/nfs-server-alpine"
LABEL branch "master"
COPY Dockerfile /Dockerfile

RUN apk add --update --verbose nfs-utils bash iproute2 && \
    rm -rf /var/cache/apk/* /tmp/* && \
    rm -f /sbin/halt /sbin/poweroff /sbin/reboot && \
    mkdir -p /var/lib/nfs/rpc_pipefs && \
    mkdir -p /var/lib/nfs/v4recovery && \
    echo "rpc_pipefs    /var/lib/nfs/rpc_pipefs rpc_pipefs      defaults        0       0" >> /etc/fstab && \
    echo "nfsd  /proc/fs/nfsd   nfsd    defaults        0       0" >> /etc/fstab

COPY confd-binary /usr/bin/confd
COPY confd/confd.toml /etc/confd/confd.toml
COPY confd/toml/* /etc/confd/conf.d/
COPY confd/tmpl/* /etc/confd/templates/

COPY nfsd.sh /usr/bin/nfsd.sh
COPY .bashrc /root/.bashrc

RUN chmod +x /usr/bin/nfsd.sh /usr/bin/confd

ENTRYPOINT ["/usr/bin/nfsd.sh"]
