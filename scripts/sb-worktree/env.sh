#!/usr/bin/env bash

# Get script dir
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export SHOULD_INIT_FILENAME='.should-init'

handle_new_worktree() {
	if [ -f "$SHOULD_INIT_FILENAME" ] && "$SCRIPT_DIR/init.sh"; then
		rm "$SHOULD_INIT_FILENAME"

		nvim
	fi
}
