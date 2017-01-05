# A terminal interface for Mattermost via the client Matterhorn
# https://github.com/matterhorn-chat/matterhorn
#
# To run, simply supply a username, hostname and (additionally) a port number.
# For example:
#
# docker run -it --rm \
#  -e MM_USER=foobar@domain.com \
#  -e MM_HOST=gitlab.mattermost.com \
#  -e MM_PORT=443 \
#  --name matterhorn \
#  cdrage/matterhorn

FROM debian:testing

#! Add Haskell
RUN apt-get update && apt-get install haskell-platform -y

#! Download and install the latest matterhorn + mattermost-api
RUN apt-get install git -y && \
      git clone https://github.com/matterhorn-chat/mattermost-api && \
      git clone https://github.com/matterhorn-chat/matterhorn

#! Build the binary (this will take a while)
RUN cd matterhorn && \
      cabal update && \
      cabal sandbox init && \
      cabal sandbox add-source ../mattermost-api && \
      cabal install --force-reinstalls && \
      cabal build

#! Copy over the entrypoint config generation script + config.ini
COPY entrypoint.sh /entrypoint.sh
COPY config.ini /config.ini
ENTRYPOINT ["/entrypoint.sh"]

#! Default environment variables
ENV MM_PORT=443

#! Run it!
CMD ["./matterhorn/dist/build/matterhorn/matterhorn", "-c", "/config.ini"]
