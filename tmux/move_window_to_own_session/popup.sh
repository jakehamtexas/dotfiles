#!/usr/bin/env bash

. $TMUX_DIR/move_window_to_own_session/fs_utils.sh

tmux popup -T 'Confirm session name' -E $TMUX_DIR/move_window_to_own_session/command.sh

target_session=$(read_session_name)
current_session=$(tmux display-message -p "#S")

tmux new-session -s $target_session -d

window_id=$(read_window_id)
old_option=$(tmux show -p detach-on-destroy)

tmux set-option -g detach-on-destroy off

tmux move-window -s $current_session:$window_id -t $target_session:1 -dk
tmux switch-client -t $target_session

tmux set-option -g detach-on-destroy ${old_option:-on}
