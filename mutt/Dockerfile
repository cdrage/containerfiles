# special thanks to jfrazelle for this config
FROM debian:stable
MAINTAINER Charlie Drage <charlie@charliedrage.com>

RUN apt-get update && apt-get install -y \
  ca-certificates \
  git \
  lynx \
  mutt-patched \
  vim-nox \
  msmtp \
  --no-install-recommends \
  && rm -rf /var/lib/apt/lists/*

# a browser is necessary!
ENV BROWSER lynx

# setup user for mutt
RUN groupadd -g 1000 user \
  && useradd --create-home -d /home/user -g user -u 1000 user
USER user
ENV HOME /home/user
ENV TERM screen-256color
RUN mkdir -p $HOME/.mutt/cache/headers $HOME/.mutt/cache/bodies && touch $HOME/.mutt/certificates
ENV LANG C.UTF-8

# copy over files
COPY  entrypoint.sh /entrypoint.sh
COPY  .mutt     $HOME/.mutt
COPY  .msmtprc     $HOME/.msmtprc

# chown on .msmtprc (it's picky)
USER root
RUN chown user:user /home/user/.msmtprc
USER user
RUN chmod 600 $HOME/.msmtprc

ENTRYPOINT ["/entrypoint.sh"]

CMD ["mutt-patched", "-F", "~/.mutt/muttrc"]

