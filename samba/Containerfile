# **Description:** 
# 
# **Source:** https://github.com/dperson/samba
# 
# Samba in a Docker container (why? why not.)
# 
# **Running:**
#
# (how I use it at least)
#
# ```sh
# docker run \
#  -it \
#  --name samba \
#  -p 139:139 \
#  -p 445:445 \
#  -p 137:137/udp \
#  -p 138:138/udp \
#  -d \
#  --network host \
#  -v /var/samba:/mount \
#  --restart=always \
#  dperson/samba \
#  -u "admin;password" \
#  -s "backup;/mount/backup;yes;no;no;admin" \
#  -w "WORKGROUP" \
#  -n  
# ``` 

FROM alpine
MAINTAINER David Personette <dperson@gmail.com>

RUN apk --no-cache --no-progress upgrade && \
    apk --no-cache --no-progress add bash samba shadow && \
    adduser -D -G users -H -g 'Samba User' -h /tmp smbuser && \
    file="/etc/samba/smb.conf" && \
    sed -i 's|^;* *\(log file = \).*|   \1/dev/stdout|' $file && \
    sed -i 's|^;* *\(load printers = \).*|   \1no|' $file && \
    sed -i 's|^;* *\(printcap name = \).*|   \1/dev/null|' $file && \
    sed -i 's|^;* *\(printing = \).*|   \1bsd|' $file && \
    sed -i 's|^;* *\(unix password sync = \).*|   \1no|' $file && \
    sed -i 's|^;* *\(preserve case = \).*|   \1yes|' $file && \
    sed -i 's|^;* *\(short preserve case = \).*|   \1yes|' $file && \
    sed -i 's|^;* *\(default case = \).*|   \1lower|' $file && \
    sed -i '/Share Definitions/,$d' $file && \
    echo '   pam password change = yes' >>$file && \
    echo '   map to guest = bad user' >>$file && \
    echo '   usershare allow guests = yes' >>$file && \
    echo '   create mask = 0664' >>$file && \
    echo '   force create mode = 0664' >>$file && \
    echo '   directory mask = 0775' >>$file && \
    echo '   force directory mode = 0775' >>$file && \
    echo '   force user = smbuser' >>$file && \
    echo '   force group = users' >>$file && \
    echo '   follow symlinks = yes' >>$file && \
    echo '   load printers = no' >>$file && \
    echo '   printing = bsd' >>$file && \
    echo '   printcap name = /dev/null' >>$file && \
    echo '   disable spoolss = yes' >>$file && \
    echo '   socket options = TCP_NODELAY' >>$file && \
    echo '   strict locking = no' >>$file && \
    echo '   vfs objects = recycle' >>$file && \
    echo '   recycle:keeptree = yes' >>$file && \
    echo '   recycle:versions = yes' >>$file && \
    echo '   min protocol = SMB2' >>$file && \
    echo '' >>$file && \
    rm -rf /tmp/*

COPY samba.sh /usr/bin/

EXPOSE 137/udp 138/udp 139 445

HEALTHCHECK --interval=60s --timeout=15s \
             CMD smbclient -L '\\localhost\' -U 'guest%' -m SMB3

VOLUME ["/etc/samba"]

ENTRYPOINT ["samba.sh"]
