#!/usr/bin/env bash

# PERSONAL CONFIG/ALIASES
export LANG=en_US.UTF-8
export PURE_POWER_MODE=modern
export POWERLEVEL9K_MODE='nerdfont-complete'
export NVIM_DIR=$HOME/.config/nvim

# KITTY
export KITTY_FONT_FAMILY="CommitMono Nerd Font"
export KITTY_THEME="CommitMono Nerd Font"
# END KITTY

GPG_TTY="$(tty)"
export GPG_TTY
EDITOR="$(which nvim)"
export EDITOR

UNAME_S="$(uname -s)"
export UNAME_S

if [ -f "$HOME/.cargo/env" ]; then
	# shellcheck source=/dev/null
	. "$HOME/.cargo/env"
fi

# GIT CONFIG
git config --global core.editor "$(which nvim)"
git config --global pull.rebase true
git config --global init.defaultBranch main
git config --global user.email 'jakehamtexas@gmail.com'
git config --global user.name 'Jake Hamilton'
git config --global fetch.prune true
git config --global push.autoSetupRemote true
