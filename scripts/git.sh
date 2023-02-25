#!/usr/bin/env bash

git_branches() {
  branches_except_current="$(git branch -al | grep -v '^\*')"
  echo "$branches_except_current" | grep '/develop' | head -n1 | xargs
  echo "$branches_except_current" | grep '\+' | cut -d' ' -f2
  echo "$branches_except_current" | grep -v '\+'
}

git_log_oneline() {
  git log --oneline "${1:-"$(git rev-parse HEAD)"}" | fzf | cut -d' ' -f1
}
