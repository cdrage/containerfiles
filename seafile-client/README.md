# seafile-client

A seafile client docker image based on [phusion/baseimage](https://hub.docker.com/r/phusion/baseimage/).

## Description

This image is meant to be used to sync a directory to a remote server.

The ccnet and seafile-daemon are run inside the container.

## Usage

run:

```
docker run -d -name seafile-sync -v /data:/var/data/seafile-data xcgd/seafile-client
```

CLI commands from seaf-cli can be run inside the container.

sync:

```
docker exec seafile-sync /usr/bin/seaf-cli sync -c /etc/ccnet -l YOUR_LIBRARY_ID -s YOUR_SEAFILE_SERVER -d /var/lib/ -u YOUR_EMAIL -p YOUR_PASSWORD
```

