#!/bin/bash
if [ -z "$1" ]
then
  echo "plz supply your commit message"
  return 1
fi
./gen.sh > README.md
git add . 
git commit -m "$1"
git push origin master
