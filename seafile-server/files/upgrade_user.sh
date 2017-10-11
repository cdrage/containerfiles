#!/usr/bin/env bash

fail() {
    echo "$1"
    exit 1
}

APP_DIR="/opt/seafile"
TOKEN="${APP_DIR}/TOKEN"
TEMP_DIR="/tmp/seafile-install"
PREFIX_SEAFILE_NAME="seafile-server-"
LATEST_NAME="${PREFIX_SEAFILE_NAME}latest"
LATEST_PATH="${APP_DIR}/${LATEST_NAME}"

[ -f ${TOKEN} ] || fail "File [${TOKEN}] doesn't exist. Are you sure you already init your data directory ?"
[ -z "${SEAFILE_VERSION}" ] && fail "You must provide a SEAFILE_VERSION in order to upgrade your seafile to that version."
[ -d "${LATEST_PATH}" ] || fail "The directory [${LATEST_PATH}] should exist and be a link to the base seafile version. Directory doesn't exist. Are you sure you already init your data directory ?"

BASE_SEAFILE_NAME="$(readlink "${LATEST_PATH}")"

[ -z "${BASE_SEAFILE_NAME}" ] && fail "The directory [${LATEST_PATH}] should exist and be a link to the base seafile version. Directory isn't a link. Are you sure you already init your data directory ?"

BASE_VERSION="${BASE_SEAFILE_NAME#${PREFIX_SEAFILE_NAME}}"

echo "Tring to upgrade from [${BASE_VERSION}] to [${SEAFILE_VERSION}]"

SEAFILE_FILENAME="seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz"
SEAFILE_TARGZ="https://download.seadrive.org/${SEAFILE_FILENAME}"
SEAFILE_INSTALLNAME="${PREFIX_SEAFILE_NAME}${SEAFILE_VERSION}"

INSTALL_DIR="${APP_DIR}/${SEAFILE_INSTALLNAME}"
UPGRADE_DIR="${INSTALL_DIR}/upgrade"
UPGRADE_SCRIPT="/opt/image/find-upgrade.py"

SEAFILE_PATH_OLD="${APP_DIR}/${PREFIX_SEAFILE_NAME}${BASE_VERSION}"
SEAFILE_PATH_NEW="${APP_DIR}/${PREFIX_SEAFILE_NAME}${SEAFILE_VERSION}"

if [ "${SEAFILE_PATH_OLD}" == "${SEAFILE_PATH_NEW}" ]
then
    echo "This seafile installation seems to already be in the target version (${SEAFILE_VERSION}). Exiting gracefully without trying to uprgade."
    exit 0
fi

mkdir -p "${TEMP_DIR}"
cd "${TEMP_DIR}"
wget --no-check-certificate "${SEAFILE_TARGZ}"
cd "${APP_DIR}"

tar xvzf "${TEMP_DIR}/${SEAFILE_FILENAME}"
rm -rf "${TEMP_DIR}"

cd "${UPGRADE_DIR}"

"${UPGRADE_SCRIPT}" "${BASE_VERSION}" "${SEAFILE_VERSION}" "${UPGRADE_DIR}" | while read scriptname
do
    echo "------------------------------------------------------------------------------"
    echo "Launching script ${scriptname}"
    echo "------------------------------------------------------------------------------"
    "./${scriptname}" || fail "The script ${scriptname} failled. Aborting."
done

if [ "${BASE_VERSION}" != "${SEAFILE_VERSION}" ]
then
    if [ "$(readlink -f "${LATEST_PATH}")" == "${SEAFILE_PATH_NEW}" ]
    then
        echo "As every upgrade scripts seems to ran fine and the new ${LATEST_PATH} seems to point to the latest version, we're removing the old directory (${SEAFILE_PATH_OLD})"
        rm -rf "${SEAFILE_PATH_OLD}"
    else
        echo "While every upgrade scripts seems to ran fine, the new ${LATEST_PATH} seems to not point to the lastest version. We're keeping the old directory (${SEAFILE_PATH_OLD}) to investigate. Good luck !"
        echo "If you made a backup before trying to upgrade, it's better to restore your backup."
    fi
fi

