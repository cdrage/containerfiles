#!/bin/sh
# Ensure that ccnet is started
sv start ccnet || exit 1
SEAFILE_CONFIG_DIR=${SEAFILE_CONFIG_DIR:-/etc/ccnet}
SEAFILE_DATA=${SEAFILE_DATA:-/var/lib/seafile}
/usr/bin/seaf-daemon -c $SEAFILE_CONFIG_DIR -d $SEAFILE_DATA
