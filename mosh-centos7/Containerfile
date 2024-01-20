# **Description:**
# Mosh = SSH + mobile connection
#
# **Running:**
#
# To normally use it:
# ```sh
# docker run -it --rm \
#   -e TERM=xterm-256color \
#   -v $HOME/.ssh:/root/.ssh \
#   cdrage/mosh user@blahblahserver
# ```
#
# How I use it (since I pipe it through a VPN):
# ```sh
# docker run -it --rm \
#   --net=container:vpn
#   -e TERM=xterm-256color \
#   -v $HOME/.ssh:/root/.ssh \
#   cdrage/mosh user@blahblahserver
# ```

FROM centos:latest

RUN yum install epel-release -y && \
    yum install openssh-clients mosh -y

RUN echo "    IdentityFile ~/.ssh/id_rsa" >> /etc/ssh/ssh_config

RUN localedef -i en_US -f UTF-8 en_US.UTF-8

ENTRYPOINT ["mosh"]
