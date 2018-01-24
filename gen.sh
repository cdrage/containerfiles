#!/bin/bash
# ./readme.sh > README.md

cat INTRO.md

for D in `find . -type d | sort`
do
  if [ -f $D/Dockerfile ]; then
        name=${D:2}
        export=`cat $D/Dockerfile | grep "#" | grep -v "#!" | sed 's/#//'`

        # Cat to README.md in each folder so it's propagated on Docker Hub correctly
        echo "$export" > $name/README.md

        # Echo to stdout
        echo "## cdrage/$name"
        echo
        echo "$export"
        echo
  fi
done
