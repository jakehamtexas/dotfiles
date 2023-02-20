#!/usr/bin/env bash

set -e

. "$TMUX_DIR"/pick_session/fs_utils.sh

if ! picked="$(tmux list-sessions | fzf)"; then
  picked="$(tmux list-clients -F '#S')"
fi

write_session_name "$picked"
