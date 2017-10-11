#!/usr/bin/env bash

fail() {
    echo "$1"
    exit 1
}

APP_DIR="/opt/seafile"
TOKEN="${APP_DIR}/TOKEN"
CLEAN_SCRIPT="${APP_DIR}/seafile-server-latest/seaf-gc.sh"

[ -f ${TOKEN} ] || fail "File [${TOKEN}] doesn't exist. Are you sure you already init your data directory ?"

sudo -E -s -u seafile "${CLEAN_SCRIPT}" "$@"


