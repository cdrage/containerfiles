#!/usr/bin/env bash

APP_DIR="/opt/seafile"
UPGRADE_USER="/opt/image/upgrade_user.sh"

fail() {
    echo "$1"
    exit 1
}

sudo -E -s -u seafile "${UPGRADE_USER}"

