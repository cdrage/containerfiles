#!/bin/sh
SEAFILE_CONFIG_DIR=${SEAFILE_CONFIG_DIR:-/etc/ccnet}
SEAFILE_DATA=${SEAFILE_DATA:-/var/lib/seafile}

if [ ! -d "$SEAFILE_CONFIG_DIR" ]; then
	mkdir -p $SEAFILE_DATA
	/usr/bin/seaf-cli init -c $SEAFILE_CONFIG_DIR -d $SEAFILE_DATA
fi
/usr/bin/ccnet -c $SEAFILE_CONFIG_DIR
