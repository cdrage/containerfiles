#!/bin/bash

/usr/bin/python /opt/graphite/bin/carbon-aggregator.py start --debug 2>&1 >> /var/log/carbon-aggregator.log
