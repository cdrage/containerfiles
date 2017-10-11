#!/bin/sh

set -eu

/usr/sbin/nginx -g "daemon off;" >> /var/log/service-nginx.log 2>&1

