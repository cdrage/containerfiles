# Nomad from Hashicorp. github.com/hashicorp/nomad
#
# To build the Nomad binary:
# git clone https://github.com/hashicorp/nomad
# cd nomad && make bin
#
# To use:
# docker run \
# --net=host \
# -v /run/docker.sock:/run/docker.sock \
# --name nomad \
# -p 4646:4646 \
# -p 4647:4647 \
# -p 4648:4648 \
# nomad agent -dev -network-interface YOURINTERFACE(eth0 probably)
#
# Now simply bash into it. Run ./nomad init && ./nomad run example.nomad
# and you'll see a redis container spring up on your host :)

FROM debian:8
MAINTAINER Charlie Drage <charlie@charliedrage.com>

RUN apt-get update && \
    apt-get install -y ca-certificates

EXPOSE :4646
EXPOSE :4647
EXPOSE :4648

COPY nomad /nomad

ENTRYPOINT ["/nomad"]

