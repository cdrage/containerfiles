#!/bin/bash
echo 'Hello from '$(hostname)'' > /www/index.html
python3 -m http.server 8080
