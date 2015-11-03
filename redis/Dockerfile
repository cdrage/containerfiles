# docker run --name redis -d -p 6379:6379 redis

FROM ubuntu:14.04
RUN apt-get update && apt-get install -y redis-server
EXPOSE 6379
ENTRYPOINT /usr/bin/redis-server
