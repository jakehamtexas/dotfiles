#!/usr/bin/env bash

set -euo pipefail

df:stow() {
	package_name=$1
	shift
	path=$1
	shift

	local full_path
	if [ -z "${APPEND_PACKAGE_NAME:-}" ]; then
		full_path="$path"
	else
		full_path="$path/$package_name"
	fi

	if ! [ -d "$package_name" ]; then
		echo "$package_name" does not exist in dotfiles
		return 1
	fi

	mkdir -p "$full_path"
	cp -fr "$package_name" "$full_path"

	# Restow has weird output that is totally spurious
	# See: https://github.com/aspiers/stow/issues/65
	echo "Stowing $package_name"
	stow -R "$package_name" -t "$full_path" "$@" || stow --adopt "$package_name" -t "$full_path" "$@"
}

df:stow:config() {
	APPEND_PACKAGE_NAME=1 df:stow "$1" ~/.config
}

df:stow:home() {
	df:stow "$1" ~
}

df:stow:config i3

df:stow:config kitty
df:stow:config nvim
df:stow:config tmux
df:stow:config skhd
df:stow:config yabai
# TODO: Remove this '|| true' when nix is everywhere
df:stow:config nix || true
APPEND_PACKAGE_NAME=1 df:stow scripts ~

df:stow:home safebase
df:stow:home scan
df:stow ssh ~/.ssh --adopt
df:stow:home xinit
df:stow:home zsh
df:stow:home shellcheck

df:stow:home direnv
