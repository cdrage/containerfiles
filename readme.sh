#!/bin/bash

echo "#Dockerfiles"
echo "Git repo for my personal Dockerfiles. README.md is auto-generated from Dockerfile comments"

for D in `find . -type d`
do
  if [ -f $D/Dockerfile ]; then
        echo "###" $D
        echo
        echo "\`\`\`bash"
        cat $D/Dockerfile | grep "#"
        echo
        echo "\`\`\`"
  fi
done


