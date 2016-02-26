#!/bin/bash
cd $HOME
echo -n "[enc] password for file: "
read -s var
openssl aes-256-cbc -d -salt -in /root/txt.enc -out /tmp/txt.txt -k $var

if [ $? -eq 0 ]; then
	echo OK
  time="\n"`date +'%G-%m-%d %H:%M'`"\n"
  echo -e $time >> /tmp/txt.txt
	vim +$ +startinsert /tmp/txt.txt
	openssl aes-256-cbc -salt -in /tmp/txt.txt -out /root/txt.enc -k $var
else
	echo FAIL
fi

rm /tmp/txt.txt
echo ""
