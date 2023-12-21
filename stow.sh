#!/usr/bin/env bash

set -e

df:stow() {
  package_name=$1
  shift
  path=$1
  shift

  local full_path
  if [ -z "$APPEND_PACKAGE_NAME" ]; then
    full_path="$path"
  else
    full_path="$path/$package_name"
  fi

  mkdir -p $full_path

  echo "Stowing $package_name"
  stow -R "$package_name" -t "$full_path" "$@"
}

df:stow:config() {
  APPEND_PACKAGE_NAME=1 df:stow $1 ~/.config
}

df:stow:config i3 
df:stow:config kitty 
df:stow:config nvim 
df:stow:config tmux 
df:stow:config skhd 
df:stow:config yabai
APPEND_PACKAGE_NAME=1 df:stow scripts ~

df:stow rustup ~/.rustup
df:stow safebase ~
df:stow scan ~
df:stow ssh ~/.ssh --adopt
df:stow xinit ~
df:stow zsh ~

