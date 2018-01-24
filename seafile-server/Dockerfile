# **Description:**
#
# **Source:** https://github.com/strator-dev/docker-seafile
#
# Okay, this Seafile Server container I've been using for a whileeeee and it's been *great*. But there are a few caveats you need to understand before deploying.
#
# First off, choose if you are going to use HTTP or HTTPS.
#
# Second, you need to make sure that SEAFILE_HOST is *actually* your domain name or a public IP address that will *NOT* change. If you set it to `0.0.0.0` you'll be able to access it and all, but come uploading/downloading files, it'll fall flat on it's face.
#
# **Environment variables:**
#
# | Variable               | Usage                                                                                                |
# |------------------------|------------------------------------------------------------------------------------------------------|
# | SEAFILE_VERSION        | Set the initial version of the Seafile Server. This will download and apply the current version set. |
# | SEAFILE_ADMIN_EMAIL    | Admin login email (this can be changed afteR)                                                        |
# | SEAFILE_ADMIN_PASSWORD | Admin password (this can be changed after)                                                           |
# | SEAFILE_HOST           | The public IP address / A record of the host                                                         |
# | SEAFILE_PORT           | Just use 8080 (fails on using 80 or 443 for some reason... too lazy to debug)                        |
# | SEAFILE_USE_HTTPS      | Set **1** to enable https and **0** to disable.                                                      | 
#
# **Running:**
# 
# ```sh
# docker run \
# -d \
# -e "SEAFILE_VERSION=6.2.2" \
# -e "SEAFILE_ADMIN_EMAIL=root@root.com" \
# -e "SEAFILE_ADMIN_PASSWORD=YOURPASSWORD" \
# -e "SEAFILE_HOST=example.domain.com" \
# -e "SEAFILE_USE_HTTPS=1" \
# -e "SEAFILE_PORT=8080" \
# -v /var/seafile:/opt/seafile \
# -p 8080:8080 \
# --name="seafile" \
# cdrage/seafile-server
# ```
#
# **Using TLS / HTTPS:**
#
# Back-in-the-day Seafile used to use their own https / TLS setup, but it ended up being buggy, cumbersome, and constantly breaking. So now they simply ask for users to reverse proxy / throw an NGINX server in-front of Seafile.
#
# To do that, I've written a tutorial on how to use Let's Encrypt and nginx-proxy to create a TLS certificate in-front of a Docker Container: https://charliedrage.com/letsencrypt-on-docker
#
# Once you've set that up, it's as simple as doing:
#
# ```sh
# docker run \
# -d \
# -e "SEAFILE_VERSION=6.2.2" \
# -e "SEAFILE_ADMIN_EMAIL=root@root.com" \
# -e "SEAFILE_ADMIN_PASSWORD=YOURPASSWORD" \
# -e "SEAFILE_HOST=example.domain.com" \
# -e "SEAFILE_USE_HTTPS=1" \
# -e "SEAFILE_PORT=8080" \
# -e "VIRTUAL_HOST=example.com.com" \
# -e "VIRTUAL_PORT="8080" \
# -v /var/seafile:/opt/seafile \
# -p 8080:8080 \
# --name="seafile" \
# cdrage/seafile-server
# ```
#
# **Problems uploading files?**
#
# So I used https://github.com/jwilder/nginx-proxy for creating a reverse proxy in-front of the container. Big problem is that by default, there is a 100MB client_max_body_size in-front of the nginx proxy. Make sure that THIS has been added to nginx-proxy:
#
# ```sh
# client_max_body_size    0;
# proxy_connect_timeout   36000s;
# proxy_read_timeout      36000s;
# proxy_request_buffering off;
# ```
#
# **Other documentation**
# There's some more documentation that I will add later, but this is based upon a source image. See: https://github.com/strator-dev/docker-seafile for more details on how to run the garbage collector, etc.



FROM phusion/baseimage:latest

ADD files /tmp/files
RUN /bin/bash /tmp/files/build-script.sh

EXPOSE 8080 80 443
