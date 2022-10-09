#!/usr/bin/env bash

readonly tmux_envvar=$TMUX_PLUGIN_MANAGER_PATH

if [ ! -d $tmux_envvar ] || [ -z $tmux_envvar ]; then
  [ ${1:-loud} = quiet ] && exit

  echo "Tmux env not set, got '$tmux_envvar' for envvar"
  exit 1
fi

$TMUX_TPM_DIR_PATH/bin/install_plugins | rg -v Already