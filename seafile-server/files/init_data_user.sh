#!/usr/bin/env bash

APP_DIR="/opt/seafile"
TOKEN="${APP_DIR}/TOKEN"
CCNET_CONF="${APP_DIR}/conf/ccnet.conf"
SEAHUB_CONF="${APP_DIR}/conf/seahub_settings.py"
TEMP_DIR="/tmp/seafile-install"

[ -z "${SEAFILE_VERSION}" ] && SEAFILE_VERSION="6.0.5"

SEAFILE_FILENAME="seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz"
SEAFILE_TARGZ="https://download.seadrive.org/${SEAFILE_FILENAME}"
SEAFILE_INSTALLNAME="seafile-server-${SEAFILE_VERSION}"

INSTALL_DIR="${APP_DIR}/${SEAFILE_INSTALLNAME}"
INSTALL_SCRIPT="./setup-seafile.sh"

PYTHON_INIT_SCRIPT="${INSTALL_DIR}/check_init_admin.py"
SEAFILE_START_SCRIPT="${INSTALL_DIR}/seafile.sh"
SEAHUB_START_SCRIPT="${INSTALL_DIR}/seahub.sh"
SEAHUB_INIT_SCRIPT="${INSTALL_DIR}/seahub-init.sh"

SEAFILE_SERVICE="${SEAFILE_HOST}"
[ -n "${SEAFILE_PORT}" ] && SEAFILE_SERVICE="${SEAFILE_HOST}:${SEAFILE_PORT}"
[ "${SEAFILE_USE_HTTPS}" == "1" ] && SEAFILE_SERVICE="https://${SEAFILE_SERVICE}" || SEAFILE_SERVICE="http://${SEAFILE_SERVICE}"

if [ ! -f "${TOKEN}" ];
then
    mkdir -p "${TEMP_DIR}"
    cd "${TEMP_DIR}"
    wget --no-check-certificate "${SEAFILE_TARGZ}"
    cd "${APP_DIR}"

    tar xvzf "${TEMP_DIR}/${SEAFILE_FILENAME}"
    rm -rf "${TEMP_DIR}"

    cd "${INSTALL_DIR}"
    "${INSTALL_SCRIPT}" auto -n seafile -i "${SEAFILE_HOST}"
    perl -i -ape 's{email = ask_admin_email\(\)}{email = os.environ.get("SEAFILE_ADMIN_EMAIL","admin\@example.com")}; s{passwd = ask_admin_password\(\)}{passwd = os.environ.get("SEAFILE_ADMIN_PASSWORD","password")};' "${PYTHON_INIT_SCRIPT}"
    perl -i -ape 's{^SERVICE_URL = .*}{SERVICE_URL = '"${SEAFILE_SERVICE}"'}' "${CCNET_CONF}"
    echo "FILE_SERVER_ROOT = '${SEAFILE_SERVICE}/seafhttp'" >> "${SEAHUB_CONF}"
    if [ -n "${SEAFILE_LDAP_URL}" ]
    then
        echo "" >> "${CCNET_CONF}"
        echo "[LDAP]" >> "${CCNET_CONF}"
        echo "HOST = ${SEAFILE_LDAP_URL}" >> "${CCNET_CONF}"
        echo "BASE = ${SEAFILE_LDAP_BASE}" >> "${CCNET_CONF}"
        echo "USER_DN = ${SEAFILE_LDAP_USER_DN}" >> "${CCNET_CONF}"
        echo "PASSWORD = ${SEAFILE_LDAP_PASSWORD}">> "${CCNET_CONF}"
        echo "LOGIN_ATTR = ${SEAFILE_LDAP_LOGIN_ATTR}">> "${CCNET_CONF}"
    fi
    bash "${SEAFILE_START_SCRIPT}" start
    cp "${SEAHUB_START_SCRIPT}" "${SEAHUB_INIT_SCRIPT}"
    perl -i -ape 's{^case}{before_start;check_init_admin;exit 0;\ncase}' "${SEAHUB_INIT_SCRIPT}"
    bash "${SEAHUB_INIT_SCRIPT}" start
    rm -f "${SEAHUB_INIT_SCRIPT}"
    touch "${TOKEN}"
fi
