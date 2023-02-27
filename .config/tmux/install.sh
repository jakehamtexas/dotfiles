#!/usr/bin/env zsh

if [ ! -d "$TMUX_PLUGIN_MANAGER_PATH" ] || [ -z "$TMUX_PLUGIN_MANAGER_PATH" ]; then
  [ "${1:-loud}" = quiet ] && exit

  echo "Tmux env not set, got '$TMUX_PLUGIN_MANAGER_PATH' for envvar"
  exit 1
fi

. lib/with_unset_git_env.sh

with_unset_git_env "$TMUX_TPM_DIR_PATH"/bin/install_plugins | grep -v Already

"$HOME"/.config/tmux/plugins/tmux-resurrect/resurrect.tmux
