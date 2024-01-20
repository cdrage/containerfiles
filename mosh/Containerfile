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

FROM ubuntu:16.04

RUN apt-get update
RUN apt-get install -y ssh mosh
RUN  echo "    IdentityFile ~/.ssh/id_rsa" >> /etc/ssh/ssh_config

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8 
ENV LC_ALL en_US.UTF-8

ENTRYPOINT ["mosh"]
