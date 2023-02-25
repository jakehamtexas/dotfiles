#!/usr/bin/env bash

set -e

[ -z "$1" ] && {
  echo 'Usage: worktree-add PATH [new-branch-name] [checkout-from-commit-ish]'
  exit 1
}

[[ -d "$1" ]] && {
  echo "Directory exists: $1"
  exit 1
}

. "$(cd "$(dirname "$0")" && pwd)/lib.sh"

issues=
id=

pick_linear_branch() {
  . "${LINEAR_ENV_PATH:-"$HOME"/.linear_env}"

  ensure_linear_env
  issues="$(query_issues)"
  id="$(fzf_issues "$issues")"
  find_branch_name "$issues" "$id"
}

branch_to_checkout="${2:-"$(pick_linear_branch || jake/tmp)"}"
base_commit_ish="${3:-"$(fzf_branches || develop)"}"

git fetch
git worktree add -b "$branch_to_checkout" "$1" "$base_commit_ish"
cd "$1"

if [ -n "$issues" ] && [ -n "$id" ]; then
  mkdir .vim
  find_issue "$issues" "$id" >.vim/issue.json
fi

touch worktree_should_init
