#!/usr/bin/env bash

if ! command -v oh-my-posh >/dev/null; then
	sudo "$ZDOTDIR"/oh-my-posh/install.sh
fi

if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
	eval "$(oh-my-posh init \
		--config "$ZDOTDIR/oh-my-posh/conf.toml" \
		zsh)"
fi
