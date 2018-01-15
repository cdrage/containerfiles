# **Description:**
#
# **Source:** https://github.com/AMilassin/docker-dodns
#
# Docker to update DigitalOcean DNS similar to DynDNS.
#
# It's as easy as running the container and then editing the configuration file.
# 
# **Running:**
#
# ```sh
# docker run \
#  --name digitalocean-dns \
#  -d \
#  -v /var/digitalocean-dns:/config:rw \
#  --restart=always \
#  cdrage/digitalocean-dns
# ``` 
#
# **Configuration:**
#
# After running, open `/var/digitalocean-dns/dodns.conf.js` and edit it to your liking.

FROM node:8.1.2-alpine
MAINTAINER amilassin

VOLUME "/config"

RUN mkdir -p /etc/my_init.d

ADD startup.sh /root/startup.sh
RUN chmod +x /root/startup.sh

ADD dodns.js /root/dodns.js
ADD dodns.conf.js.default /root/dodns.conf.js.default

ADD dodns_periodic.sh /etc/periodic/15min/dodns
RUN chmod +x /etc/periodic/15min/dodns

CMD ["/root/startup.sh"]
