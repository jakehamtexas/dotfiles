#!/usr/bin/env zsh

if [ ! -d "$TMUX_TPM_DIR_PATH" ]; then
  git clone https://github.com/tmux-plugins/tpm "$TMUX_TPM_DIR_PATH"
fi

"$TMUX_TPM_DIR_PATH"/bin/install_plugins

"$HOME"/.config/tmux/plugins/tmux-resurrect/resurrect.tmux
