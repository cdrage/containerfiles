FROM debian:sid

RUN apt-get update && \
    apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    python3 &&\
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY main.sh /
RUN mkdir /www

EXPOSE 80

WORKDIR /www

ENTRYPOINT ["/main.sh"]
