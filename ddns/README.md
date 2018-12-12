 **Description:**

 Dynamic DNS for DigitalOcean

 **Source**: https://github.com/gbolo/dockerfiles/tree/master/digitalocean-ddns

 **Running:**

 ```sh
 docker run \
 -d \
 --restart always \
 -e DODDNS_TOKEN=your_api_key \
 -e DODDNS_DOMAIN=your.domain.com \
 cdrage/ddns
 ```
