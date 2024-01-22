#!/bin/bash
# ./readme.sh > README.md

# Temporary file to hold the Table of Contents
TOC_FILE=$(mktemp)

# Header for Table of Contents
echo "" >> $TOC_FILE
echo "## Table of Contents" > $TOC_FILE
echo "" >> $TOC_FILE

cat INTRO.md

# First pass to generate Table of Contents
for D in $(find . -type d | sort); do
  if [ -f "$D/Containerfile" ]; then
    name=${D:2}
    # Adding entry to the Table of Contents, removing 'cdrage/' prefix
    echo "- [$name](#$name)" >> $TOC_FILE
  fi
done

# Output the Table of Contents
cat $TOC_FILE
echo ""

# Clean up the temp file
rm $TOC_FILE

# Second pass to generate the actual content
for D in $(find . -type d | sort); do
  if [ -f "$D/Containerfile" ]; then
    name=${D:2}
    export=$(cat $D/Containerfile | grep "#" | grep -v "#!" | sed 's/#//')

    # Cat to README.md in each folder so it's propagated on the hub anyways
    echo "$export" > $name/README.md

    # Echo to stdout with adjusted link (remove 'cdrage/' if you want it more generic)
    echo "## [$name](/$name/Containerfile)"
    echo
    echo "$export"
    echo
  fi
done
