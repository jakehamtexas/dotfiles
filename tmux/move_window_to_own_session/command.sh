#!/usr/bin/env bash

# shellcheck disable=SC1091
. "${TMUX_DIR:?}"/move_window_to_own_session/fs_utils.sh

window_name=$(tmux display-message -p "#W")
prompt_session_name "$window_name"

window_id=$(tmux display-message -p "#{window_id}")
write_window_id "$window_id"
