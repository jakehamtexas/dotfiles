#!/usr/bin/env bash

wget -O "$HOME"/dotfiles.alias https://raw.githubusercontent.com/jakehamtexas/dotfiles/main/dotfiles.alias
source "$HOME"/dotfiles.alias
git clone --bare git@github.com:jakehamtexas/dotfiles.git "$DOTFILES_GIT_DIR"
