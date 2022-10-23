#!/usr/bin/env bash

. $TMUX_DIR/safebase/fs_utils.sh


search_linear_issues() {
  issues=$(printf 'linear1\nlinear2')
  echo $(tmux list-sessions) | fzf
}

handle_linear() {
  choice=$(search_linear_issues)

  write_linear_issue $choice

  prompt_session_name
}

handle_custom() {
  prompt_session_name
}

handle_create() {
  read -n1 -p '(l)inear or (c)ustom?' -r
  printf '\n'

  case $REPLY in
    l) handle_linear;;
    c) handle_custom;;
  esac
}

handle_find() {
  sessions=$(tmux list-sessions)
  selection=$(printf "$sessions" | fzf)

  # Select tmux session
}

read -n1 -p '(c)reate or (f)ind session?' -r
printf '\n'

case $REPLY in
  c) handle_create;;
  f) handle_find;;
  *) exit 1
esac
