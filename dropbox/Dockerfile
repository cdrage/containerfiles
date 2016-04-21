# docker run -d -e UID=$(id -u) -v ~/.dropbox:/home/.dropbox -v ~/dropbox:/home/Dropbox --name dropbox $USER/dropbox

FROM debian:wheezy
MAINTAINER Charlie Drage <charlie@charliedrage.com>

ADD http://www.dropbox.com/download?plat=lnx.x86_64 /dropbox.tgz
RUN cd /home && tar xzf /dropbox.tgz && rm /dropbox.tgz

RUN mkdir -p /home/.dropbox /home/Dropbox
ADD startup.sh /startup.sh
ADD rundropbox.sh /home/rundropbox.sh
RUN chmod +x /startup.sh /home/rundropbox.sh
CMD /startup.sh
