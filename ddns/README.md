 **Description:**

 Dynamic DNS for DigitalOcean

 **Source**: https://github.com/gbolo/dockerfiles/tree/master/digitalocean-ddns

 **Running:**

 ```sh
 podman run \
 -d \
 --restart always \
 -e DODDNS_TOKEN=your_api_key \
 -e DODDNS_DOMAIN=your.domain.com \
 ghcr.io/cdrage/ddns
 ```
