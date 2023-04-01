#!/usr/bin/env bash

set -e

. "$TMUX_DIR"/pick_session/fs_utils.sh

if ! picked="$(tmux list-windows -a -F '#S|#W|#{pane_current_path}' | fzf | cut -d'|' -f1)" || [ -z "$picked" ]; then
  picked="$(tmux list-clients -F '#S')"
fi

write_session_name "$picked"
