#!/usr/bin/env bash

set -e

# From home directory
git clone git@github.com:jakehamtexas/dotfiles.git dotfiles

(cd dotfiles && ./stow.sh)

