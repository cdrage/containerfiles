# Encrypted journal (for writing, not logs!)
# docker run -it --rm -v /bin/txt.aes:/txt.aes jrl

FROM debian:jessie

RUN apt-get update && apt-get install openssl vim -y

ADD journal.sh journal.sh

CMD ["./journal.sh"]

