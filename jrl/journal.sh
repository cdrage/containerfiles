#!/bin/bash
cd $HOME
echo -n "[enc] password for file: "
read -s var
openssl aes-256-cbc -d -md md5 -salt -in /tmp/txt.enc -out /tmp/txt.txt -k $var

if [ $? -eq 0 ]; then
	echo OK
  time="\n"`date +'%G-%m-%d %H:%M'`"\n"
  echo -e $time >> /tmp/txt.txt
	vim +$ +startinsert /tmp/txt.txt
	openssl aes-256-cbc -md md5 -salt -in /tmp/txt.txt -out /tmp/txt.enc -k $var
else
	echo FAIL
fi

# Make sure
rm /tmp/txt.txt
echo ""
