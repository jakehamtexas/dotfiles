#!/bin/bash

set -e

dir='merge-conflict-test-repo-dir'
mkdir "$dir"
cd "$dir" || exit
git init
touch my_code.sh
echo "disable=all" >.shellcheckrc
git add my_code.sh
echo "echo Hello" >my_code.sh
git commit -am 'initial'
git checkout -b new_branch
echo "echo \"Hello World\"" >my_code.sh
git commit -am 'first commit on new_branch'
git checkout main
echo "echo \"Hello World!\"" >my_code.sh
git commit -am 'second commit on main'
git merge new_branch
