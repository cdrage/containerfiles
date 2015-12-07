#!/bin/bash
./gen.sh > README.md
git add . 
git commit -m "$1"
git push origin master
