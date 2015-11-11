# YAY! Libvirtd within Docker! USE DAT KVM VIRTUALIZATION
# Although this doesn't work very well at the moment (see KVM module errors)
#
# docker run
# --privileged \
# --net=host
# -p 16509:16509
# -v /var/lib/libvirt:/var/lib/libvirt
# --name libvirtd libvirtd
#
# to connect (on client): virsh --connect qemu+tcp://localhost/system

FROM debian:jessie

RUN apt-get update && \
    apt-get install -y qemu-kvm libvirt-daemon supervisor

RUN apt-get install -y libvirt-daemon-system --no-install-recommends

RUN echo "listen_tls = 0" >> /etc/libvirt/libvirtd.conf; \
    echo 'listen_tcp = 1' >> /etc/libvirt/libvirtd.conf; \
    echo 'tls_port = "16514"' >> /etc/libvirt/libvirtd.conf; \ 
    echo 'tcp_port = "16509"' >> /etc/libvirt/libvirtd.conf; \
    echo 'auth_tcp = "none"' >> /etc/libvirt/libvirtd.conf

COPY supervisor.conf /supervisor.conf
EXPOSE 16509
CMD ["/usr/sbin/libvirtd", "-l"]
