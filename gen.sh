#!/bin/bash
# ./readme.sh > README.md

echo ""
echo "Personal Dockerfiles. README.md is auto-generated from Dockerfile comments"
echo ""
echo "List of recommended conatainers: [INDEX](INDEX.md)"

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
