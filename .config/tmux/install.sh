#!/usr/bin/env zsh

if [ ! -d "$TMUX_TPM_DIR_PATH" ]; then
  with_unset_git_env git clone https://github.com/tmux-plugins/tpm "$TMUX_TPM_DIR_PATH"
fi

which with_unset_git_env

with_unset_git_env "$TMUX_TPM_DIR_PATH"/bin/install_plugins

"$HOME"/.config/tmux/plugins/tmux-resurrect/resurrect.tmux
