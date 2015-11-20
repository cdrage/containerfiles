# Original source: github.com/pandrew/dockerfiles
# build it yo:
# docker build -t nmap .
#
# and run it!
# docker run --rm -it --net=host --cap-add=NET_ADMIN nmap
#
# ex.
# docker run --rm -it --net=host --cap-add=NET_ADMIN nmap -v scanme.nmap.org

FROM debian:jessie

ENV VERSION 7.00
RUN apt-get update && apt-get -y install build-essential wget bzip2

RUN wget http://nmap.org/dist/nmap-${VERSION}.tar.bz2 && \
	bzip2 -cd nmap-${VERSION}.tar.bz2 | tar xvf - && \
	cd nmap-${VERSION} && \
	./configure && \
	make && \
	make install && \
	cd && \
	rm -rf nmap-${VERSION}

ENTRYPOINT ["nmap"]
