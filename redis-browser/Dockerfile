# just run docker run -p 4567:4567 $USER/redis-browser

FROM debian:sid

RUN apt-get update && apt-get install -y ruby

RUN gem install redis-browser

EXPOSE 4567

CMD ["redis-browser"]
