#!/usr/bin/env /bin/bash

if [ ! -d $TMUX_PLUGIN_MANAGER_PATH ]; then
  echo 'tmux env not set'
  exit 1
fi

$($TMUX_TPM_DIR_PATH/bin/install_plugins | rg -v Already)
