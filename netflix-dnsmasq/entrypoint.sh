#!/bin/bash
set -e

sed -i "s,%PROXYIP%,$IP,g" /etc/dnsmasq.conf

exec "$@" 
