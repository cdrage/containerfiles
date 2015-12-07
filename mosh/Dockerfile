# 
# docker run -it --rm \
# -e TERM=xterm-256color \
# -v $HOME/.ssh:/root/.ssh \
# $USER/mosh user@blahblahserver
#
# how i use it:
# docker run -it --rm \
# --net=container:vpn
# -e TERM=xterm-256color \
# -v $HOME/.ssh:/root/.ssh \
# $USER/mosh user@blahblahserver
# 

FROM ubuntu:15.10

RUN apt-get update
RUN apt-get install -y ssh mosh
RUN  echo "    IdentityFile ~/.ssh/id_rsa" >> /etc/ssh/ssh_config

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8 
ENV LC_ALL en_US.UTF-8

ENTRYPOINT ["mosh"]
