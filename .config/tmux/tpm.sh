#!/usr/bin/env zsh

. lib/with_unset_git_env.sh

with_unset_git_env git clone https://github.com/tmux-plugins/tpm $TMUX_TPM_DIR_PATH
