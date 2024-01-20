#!/bin/bash
# ./readme.sh > README.md

cat INTRO.md

for D in `find . -type d | sort`
do
  if [ -f $D/Containerfile ]; then
        name=${D:2}
        export=`cat $D/Containerfile | grep "#" | grep -v "#!" | sed 's/#//'`

        # Cat to README.md in each folder so it's propagated on the hub anyways
        echo "$export" > $name/README.md

        # Echo to stdout
        echo "## [cdrage/$name](/$name/Containerfile)"
        echo
        echo "$export"
        echo
  fi
done
