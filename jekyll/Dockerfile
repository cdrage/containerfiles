# docker run --label=jekyll --volume=$(pwd):/srv/jekyll -d -p 80:4000 --restart=always jekyll/jekyll jekyll s

FROM ruby:2.1

RUN apt-get update \
  && apt-get install -y \
    node \
    python-pygments \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/

RUN gem install \
  jekyll \
  redcarpet \
  rouge

VOLUME /src
EXPOSE 4000

WORKDIR /src
ENTRYPOINT ["jekyll"]
