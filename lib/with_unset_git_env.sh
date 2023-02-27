#!/usr/bin/env bash

with_unset_git_env() {
  readonly git_dir=$GIT_DIR
  readonly git_wt=$GIT_WORK_TREE

  unset GIT_DIR
  unset GIT_WORK_TREE

  $@ || true
  
  export GIT_DIR=$git_dir
  export GIT_WORK_TREE=$git_wt
}

