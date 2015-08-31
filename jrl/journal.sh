#!/bin/bash
cd $HOME
echo -n "[enc] password for file: "
read -s var
openssl aes-256-cbc -d -salt -in /root/txt.aes -out /tmp/txt.txt -k $var

if [ $? -eq 0 ]; then
	echo OK
	vim +$ +startinsert /tmp/txt.txt
	openssl aes-256-cbc -salt -in /tmp/txt.txt -out /root/txt.aes -k $var
else
	echo FAIL
fi
rm /tmp/txt.txt
echo ""
