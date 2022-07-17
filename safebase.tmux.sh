#!/bin/bash

session_base="base"
if [ "$(tmux list-sessions | grep $session_base)" = "" ]; then
  tmux new-session -d -s $session_base

  tmux rename-window -t 0 'notes'
  tmux send-keys -t 'notes' 'cd ~/projects/notes' C-m 'vim' C-m

  tmux new-window -t $session_base:1 -n 'main'
  tmux send-keys -t 'main' 'cd ~/projects/monorepo/main' C-m 'git pull' C-m './prepare_dev.sh' C-m

  tmux new-window -t $session_base:2 -n 'develop'
  tmux send-keys -t 'develop' 'cd ~/projects/monorepo/develop' C-m 'git pull' C-m './prepare_dev.sh' C-m
fi

session_active="active"
if [ "$(tmux list-sessions | grep $session_active)" = "" ]; then
  tmux new-session -d -c projects/monorepo -s $session_active

  tmux attach-session -t $session_active:0
fi
