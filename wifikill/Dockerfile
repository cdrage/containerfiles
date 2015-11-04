# DISCLAIMER: Only use this on YOUR OWN network. This script is not responsible for any damages it causes.
# This uses ARP spoofing: https://en.wikipedia.org/wiki/ARP_spoofing by sending a fake MAC address to the victom believing it to be the gateway
# 
# To use:
# docker run --rm -it --net=host --cap-add=NET_ADMIN wifikill 

FROM debian:sid

RUN apt-get update && \
    apt-get install git tcpdump libpcap0.7 libpcap-dev python-scapy -y

RUN git clone https://github.com/charliedrage/wifikill

CMD ["python", "/wifikill/wifikill.py"]
