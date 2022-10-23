#!/usr/bin/env bash

. $TMUX_DIR/pick_session/fs_utils.sh

picked="$(echo "$(tmux list-sessions)" | fzf)"

write_session_name $picked

