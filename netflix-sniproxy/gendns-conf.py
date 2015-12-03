#!/usr/bin/python
from __future__ import print_function
import sys
import argparse
import re

DEMO_IP = '199.233.247.225'

parser = argparse.ArgumentParser(description='Dockerflix DNS config builder')
parser.add_argument('-r', '--remoteip', help='Dockerflix public server IP address', default=DEMO_IP, required=False)
parser.add_argument('-c', '--configdir', help='Dockerflix config dir', default='./config', required=False)
parser.add_argument('-t', '--type', help='DNS config type', choices=['dnsmasq', 'bind'], default='dnsmasq', required=False)
parser.add_argument('-d', '--dnsmasqdir', help='Dnsmasq config dir', default='/etc/dnsmasq.d', required=False)
parser.add_argument('-b', '--binddir', help='BIND config dir', default='/etc/bind', required=False)
parser.add_argument('-y', '--region', help='Region', choices=['us', 'uk'], default='us', required=False)
args = parser.parse_args()

if args.region != 'us' and args.remoteip == DEMO_IP:
  sys.exit('No demo server for this region available, please specify --remoteip')

f = open(args.configdir + '/' + args.region + '-dockerflix-dnsmasq.conf')
istr = f.read()
f.close
ostr = istr.replace('{IP}', args.remoteip)
f = open(args.configdir + '/' + args.region + '-dockerflix-dnsmasq-exclude.conf')
exstr = f.read()
f.close

if args.type == 'dnsmasq':
  print('#### paste this into your router\'s dnsmasq configuration ' + args.dnsmasqdir + '/' + args.region + '-' + 'dockerflix.conf')
  print(exstr, end='')
  print(ostr)
elif args.type == 'bind':
  print('#### paste this into your router\'s BIND configuration ' + args.binddir + '/' + args.region + '-' + 'dockerflix.zones and include it in your BIND configuration')
  print(re.sub(r"address=/(.*)/(.*)", 'zone \"\g<1>.\" {\n\ttype master;\n\tfile \"' + args.binddir + '/db.' + args.region + '-' + 'dockerflix\";\n};\n', ostr, flags=re.MULTILINE), end='')
  print(re.sub(r"server=/(.*)/(.*)", 'zone \"\g<1>.\" {\n\ttype master;\n\tforwarders { \g<2>; };\n};\n', exstr, flags=re.MULTILINE))
  print('\n;#### paste this into your router\'s BIND configuration ' + args.binddir + '/db.' + args.region + '-' + 'dockerflix')
  print('$TTL 86400\n@\tIN SOA ns1 root.localhost. (\n\t2012100401\n\t604800\n\t86400\n\t2419200\n\t86400\n\t)\n\n@\tIN NS ns1\nns1\tIN A ' + args.remoteip + '\n@\tIN A ' + args.remoteip + '\n*\tIN A ' + args.remoteip + '\n')
