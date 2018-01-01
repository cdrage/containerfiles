#!/bin/bash
# ./readme.sh > README.md

cat INTRO.md

for D in `find . -type d | sort`
do
  if [ -f $D/Dockerfile ]; then
        name=${D:2}
        echo "## cdrage/$name"
        echo
        cat $D/Dockerfile | grep "#" | grep -v "#!" | sed 's/#//'
        echo
  fi
done
