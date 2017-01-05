# Description:
#
# SSH in a Docker container :)

FROM alpine:latest

RUN apk update && \
    apk add bash openssh && \
    rm -rf /var/cache/apk/*

ENTRYPOINT ["ssh"]
