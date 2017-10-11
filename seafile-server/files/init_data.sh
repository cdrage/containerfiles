#!/usr/bin/env bash

SEAHUB_START_IMAGE="/opt/image/seahub.start"
SEAHUB_START="/etc/service/seahub/run"
APP_DIR="/opt/seafile"
INIT_DATA_USER="/opt/image/init_data_user.sh"

mkdir -p "${APP_DIR}"
chown seafile:seafile "${APP_DIR}"
sudo -E -s -u seafile "${INIT_DATA_USER}"
[ -f "${SEAHUB_START_IMAGE}" ] && mv "${SEAHUB_START_IMAGE}" "${SEAHUB_START}"

cd .
