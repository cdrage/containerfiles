Wifi Kill
========

Uses [ARP spoofing](https://en.wikipedia.org/wiki/ARP_spoofing) to prevent users on the same WLAN for accessing the internet. Script uses Python to send a bad gateway MAC address (12:34:56:78:9A:BC) to the victim, preventing them from accessing tthe internet.


To use this script:
  1. Build the docker container `docker build -t wifikill .`
  2. Run it `docker run --rm -it --net=host --cap-add=NET_ADMIN wifikill`
