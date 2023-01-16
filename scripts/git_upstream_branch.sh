#!/usr/bin/env bash

branch_name="${1:-develop}"

first_found_upstream=$(git remote -v | awk '{ print $1 }' | head -n 1)
upstream=${first_found_upstream:-origin}

echo "$upstream"/"$branch_name"
