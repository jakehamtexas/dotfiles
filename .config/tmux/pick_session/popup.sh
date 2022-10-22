#!/usr/bin/env bash

. $TMUX_DIR/pick_session/fs_utils.sh

tmux popup -T 'Select a session' -E $TMUX_DIR/pick_session/command.sh

session_name=$(read_session_name)
tmux switch-client -t $session_name
