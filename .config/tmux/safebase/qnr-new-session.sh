#!/usr/bin/env bash

. $TMUX_DIR/safebase/fs_utils.sh

tmux popup -T 'Select a session type' -E $TMUX_DIR/safebase/create_session.sh

session_name=$(read_session_name)
tmux new-session -s $session_name -d
tmux switch-client -t $session_name
