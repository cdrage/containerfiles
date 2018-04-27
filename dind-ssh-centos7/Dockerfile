# Dockerfile to allow the ability to run docker-in-docker and an SSH server.

# See: https://github.com/docker-library/docs/tree/master/centos#systemd-integration
# Also: https://github.com/moby/moby/issues/35317
#
FROM cdrage/centos7-systemd
MAINTAINER The CentOS Project <cloud-ops@centos.org>

#! iproute so Ansible can retrieve the ipv4 address
#! selinux for setting it permissive
#! libselinux-python for interaction with selinux
#! docker because ya know
#! cronie / crontab added as well
#! initscripts because of https://github.com/CentOS/sig-cloud-instance-images/issues/28
RUN yum -y install openssh-server \
      sshpass \
      sudo \
      openssh-clients \
      passwd \
      libselinux-python \
      selinux-policy \
      iptables \
      iproute \
      docker \
      cronie \
      initscripts && \
      yum clean all
ADD ./start.sh /start.sh
RUN mkdir /var/run/sshd

RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' 

RUN chmod 755 /start.sh
RUN ./start.sh && systemctl enable sshd.service && systemctl enable docker.service

CMD ["/usr/sbin/init"]
