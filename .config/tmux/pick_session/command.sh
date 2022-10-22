#!/usr/bin/env bash

. $TMUX_DIR/pick_session/fs_utils.sh

clear_tmp_dir
picked="$(echo "$(tmux list-sessions)" | fzf)"

write_session_name $picked

