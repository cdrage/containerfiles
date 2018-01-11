#!/bin/sh

echo "Running startup script...."

echo "Fixing permissions"
chmod -R go+rw /config

if [ ! -f "/config/dodns.conf.js" ]; then
  echo "Copying configuration file..."
  cp /root/dodns.conf.js.default /config/dodns.conf.js
fi

ln -s /config /root/config

echo "Startup script: DONE"


# run script for first time
node /root/dodns.js > /config/dodns.log 2>&1


# start cron daemon (in frontend, so the docker container sticks)
crond -fS
