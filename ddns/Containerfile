# **Description:**
#
# Dynamic DNS for DigitalOcean
#
# **Source**: https://github.com/gbolo/dockerfiles/tree/master/digitalocean-ddns
#
# **Running:**
#
# ```sh
# docker run \
# -d \
# --restart always \
# -e DODDNS_TOKEN=your_api_key \
# -e DODDNS_DOMAIN=your.domain.com \
# cdrage/ddns
# ```

FROM golang:1.11.2-stretch AS builder

RUN apt-get install git make -y

ARG   do_ddns_version=master

RUN   set -xe; \
      SRC_DIR=${GOPATH}/src/github.com/gesquive/digitalocean-ddns; \
      SRC_REPO=https://github.com/gesquive/digitalocean-ddns; \
      mkdir -p ${SRC_DIR} && \
      git clone -b master --single-branch ${SRC_REPO} ${SRC_DIR} && \
      cd ${SRC_DIR}; \
      if [ "${do_ddns_version}" != "master" ]; then git checkout ${do_ddns_version}; fi && \
      make deps && make install


FROM golang:1.11.2-stretch

COPY  --from=builder /usr/local/bin/digitalocean-ddns /usr/local/bin/digitalocean-ddns

#! Run as non-privileged user by default
USER  65534

#! Inherit gbolo/baseos entrypoint and pass it this argument
CMD  ["/usr/local/bin/digitalocean-ddns"]
