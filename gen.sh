#!/bin/bash
# ./readme.sh > README.md

cat INTRO.md

for D in `find . -type d | sort`
do
  if [ -f $D/Dockerfile ]; then
        echo "###" $D
        echo
        echo "\`\`\`"
        cat $D/Dockerfile | grep "#" | grep -v "#!" | sed 's/#//'
        echo
        echo "\`\`\`"
  fi
done
