#!/bin/bash
# This will run as the dropbox user in /home
echo "Starting Dropbox daemon"
~/.dropbox-dist/dropboxd
echo "Dropbox daemon quit with status $?"

