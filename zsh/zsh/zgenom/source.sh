#!/usr/bin/env bash

# Docs: https://github.com/jandamm/zgenom

export ZGEN_RESET_ON_CHANGE="$ZDOTDIR/zgenom/source.sh"

__install_manager() {
	local z_path="${HOME}/.zgenom/zgenom.zsh"

	if ! [ -f "$z_path" ]; then
		git clone https://github.com/jandamm/zgenom.git "$(dirname "$z_path")"
	fi

	source "$z_path"
}

__install_plugins() {
	# Check for plugin and manager updates every 7 days
	# This does not increase the startup time.
	zgenom autoupdate

	if ! zgenom saved; then
		omz_plugins=(
			git
			docker
			docker-compose
		)

		# Add this if you experience issues with missing completions or errors mentioning compdef.
		zgenom compdef

		[[ "$(uname -s)" = Darwin ]] && zgenom ohmyzsh plugins/macos

		zgenom ohmyzsh

		for plugin in "${omz_plugins[@]}"; do
			zgenom ohmyzsh plugins/"$plugin"
		done

		zgenom load 'MichaelAquilina/zsh-history-filter'
		zgenom load 'zsh-users/zsh-autosuggestions'
		zgenom load 'zsh-users/zsh-syntax-highlighting'
		zgenom load 'b4b4r07/enhancd'
		zgenom load 'unixorn/fzf-zsh-plugin'
		zgenom load 'lukechilds/zsh-nvm'

		zgenom save

		zgenom compile "$ZDOTDIR"
	fi
}

__install_manager
__install_plugins

unset -f __install_manager
unset -f __install_plugins
