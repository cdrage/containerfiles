#!/bin/bash
set -e

if ! echo "$UID" | grep -qE ^?[0-9]+$ || [ "$UID" -eq "0" ]; then
  echo "Environment variable \$UID needs to be set to the user who should " \
       "own files."
  exit 1
fi

echo "Dropbox container starting up with UID $UID"

chown $UID /home/.dropbox /home/Dropbox /home

# checks if user was created (incase docker restarts dropbox container), if not, create one
id -u dropbox &>/dev/null || useradd -u $UID -d /home dropbox

# dont know why this doesnt 666 on install, will investigate later
chmod 666 /home/.dropbox-dist/dropbox-lnx.x86_64-3.6.7/futures-2.1.3-py2.7.egg/EGG-INFO/top_level.txt || true
su --login dropbox /home/rundropbox.sh
