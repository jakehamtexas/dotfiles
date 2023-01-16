#!/usr/bin/env bash

if [[ -n $1 ]]; then
  git checkout "$1"
  return
fi

branches_except_current=$(git branch -av --color=always | /usr/bin/grep -v '\*')

chosen_branch=$(echo "$branches_except_current" |
  fzf --ansi \
    --preview \
    "echo {} | tr -s ' ' | cut -d' ' -f2 | xargs git log --oneline --color=always" \
    --preview-window \
    nohidden |
  awk '{ print $1 }')

git checkout "$chosen_branch"
