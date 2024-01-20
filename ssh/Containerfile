# **Description:**
# SSH in a Docker container :)
#
# **Running:**
#
# To normally use it:
# ```sh
# docker run -it --rm \
#   -e TERM=xterm-256color \
#   -v $HOME/.ssh:/root/.ssh \
#   cdrage/ssh user@blahblahserver
# ```
#
# How I use it (since I pipe it through a VPN):
# ```sh
# docker run -it --rm \
#   --net=container:vpn
#   -e TERM=xterm-256color \
#   -v $HOME/.ssh:/root/.ssh \
#   cdrage/ssh user@blahblahserver
# ```

FROM alpine:latest

RUN apk update && \
    apk add bash openssh && \
    rm -rf /var/cache/apk/*

ENTRYPOINT ["ssh"]
