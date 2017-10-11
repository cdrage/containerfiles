# **Description:**
#
# Source: https://bitbucket.org/xcgd-team/seafile-client
# After a lot of frustation, I've taken the solution from: https://bitbucket.org/xcgd-team/seafile-client
# and fiddled around with it for my needs.
#
# **Running:**
#
# ```sh
#  docker run \
#  -d \
#  --name seafile-client \
#  -v ~/seafile:/data \
#  --restart=always \
#  cdrage/seafile-client
# ```
#
# The seaf-cli is accessible via:
#
# ```sh
# docker exec seafile-sync /usr/bin/seaf-cli
# ```
#
# In order to "add" a folder, you must sync it via the "sync" command line action
#
# ```sh
# docker exec seafile-sync /usr/bin/seaf-cli sync -l YOUR_LIBRARY_ID -s YOUR_SEAFILE_SERVER -d /data/YOUR_FOLDER -u YOUR_EMAIL -p YOUR_PASSWORD
# ```


FROM phusion/baseimage:0.9.20

CMD ["/sbin/my_init"]

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install software-properties-common
RUN apt-add-repository ppa:seafile/seafile-client
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install seafile-cli

RUN mkdir /etc/service/ccnet
COPY ccnet.sh /etc/service/ccnet/run
RUN chmod +x /etc/service/ccnet/run
RUN mkdir /etc/service/seafiled
COPY seafiled.sh /etc/service/seafiled/run
RUN chmod +x /etc/service/seafiled/run

# ln -s
RUN ln -s /etc/ccnet /root/.ccnet
