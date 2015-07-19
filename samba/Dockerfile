# source: https://github.com/JensErat/docker-samba-publicshare
# docker run -d  -p 445:445 -p 137:137 -p 138:138 -p 139:139 -v /srv/samba:/srv --env workgroup=workgroup samba

FROM debian:jessie
MAINTAINER Charlie Drage <charlie@charliedrage.com>

VOLUME /srv
EXPOSE 137 138 139 445

ENV DEBIAN_FRONTEND noninteractive

RUN \
	apt-get update && \
	apt-get install --no-install-recommends -y samba && \
	apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY smb.conf /etc/samba/smb.conf

# Pregenerate password database to prevent warning messages on container startup
RUN /usr/sbin/smbd && sleep 10 && smbcontrol smbd shutdown

ENTRYPOINT /usr/sbin/smbd -FSD -d1 --option=workgroup=${workgroup:-workgroup}
