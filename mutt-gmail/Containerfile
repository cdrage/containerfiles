# **Description:**
#
# My mutt configuration in a docker container
#
# **Running:**
#
# ```sh
# docker run -it --rm \
#    -e TERM=xterm-256color \
#    -e MUTT_NAME \
#    -e MUTT_EMAIL \
#    -e MUTT_PASS \
#    -e MUTT_PGP_KEY \
#    -v $HOME/.gnupg:/home/user/.gnupg \
#    -v $HOME/dropbox/etc/signature:/home/user/.mutt/signature \
#    -v $HOME/dropbox/etc/aliases:/home/user/.mutt/aliases \
#    -v /etc/localtime:/etc/localtime:ro \
#    cdrage/mutt-gmail
# ```

FROM debian:stable
LABEL maintainer="Charlie Drage <charlie@charliedrage.com>"

RUN apt-get update && apt-get install -y \
  ca-certificates \
  git \
  lynx \
  elinks \
  mutt-patched \
  vim \
  msmtp \
  urlview \
  --no-install-recommends \
  && rm -rf /var/lib/apt/lists/*

ENV BROWSER lynx

RUN groupadd -g 1000 user \
  && useradd --create-home -d /home/user -g user -u 1000 user
USER user
ENV HOME /home/user
ENV TERM screen-256color
RUN mkdir -p $HOME/.mutt/cache/headers $HOME/.mutt/cache/bodies && touch $HOME/.mutt/certificates
ENV LANG C.UTF-8

#! copy over files
COPY  entrypoint.sh /entrypoint.sh
COPY  .mutt     $HOME/.mutt
COPY  .msmtprc     $HOME/.msmtprc

USER root
RUN chown user:user /home/user/.msmtprc
USER user
RUN chmod 600 $HOME/.msmtprc

ENTRYPOINT ["/entrypoint.sh"]

CMD mutt-patched -F ~/.mutt/muttrc
