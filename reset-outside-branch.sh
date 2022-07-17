#!/bin/sh
rev=$1
files=$(git diff --name-only $rev)

for file in $files; do
  commits=$(git log --follow --pretty=reference develop..$rev -- $file | awk '{ print $1 }' | tac)
  if [ ! -z "$commits" ]
  then
    echo "$file"
    echo "$commits"
    echo ""
    for c in $commits; do
      git show --skip-to=$file $c
    done
  fi
done
