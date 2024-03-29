#!/usr/bin/env bash

set -e

main() {
	[ -z "$1" ] && {
		echo 'Usage: worktree-add PATH [new-branch-name] [checkout-from-commit-ish]'
		exit 1
	}

	[[ -d "$1" ]] && {
		echo "Directory exists: $1"
		exit 1
	}

	. "$(cd "$(dirname "$0")" && pwd)/lib.sh"

	local issues id

	pick_linear_branch() {
		# shellcheck disable=SC1090
		. "${LINEAR_ENV_PATH:-"$HOME"/.linear_env}"

		ensure_linear_env
		issues="$(query_issues)"
		id="$(fzf_issues "$issues")"

		if [ -z "$id" ]; then
			return 1
		fi

		find_branch_name "$issues" "$id"
	}

	branch_to_checkout="${2:-"$(pick_linear_branch || true)"}"
	base_commit_ish="${3:-"$(fzf_branches || echo develop)"}"

	git fetch

	if [ -z "$branch_to_checkout" ]; then
		git worktree add "$1" "$base_commit_ish"
	else
		git worktree add -b "$branch_to_checkout" "$1" "$base_commit_ish"
	fi

	cd "$1"

	if [ -n "$issues" ] && [ -n "$id" ]; then
		mkdir .vim
		find_issue "$issues" "$id" >.vim/issue.json
	fi

	touch "${SHOULD_INIT_FILENAME:?}"

	{
		echo ""
		echo "Starting ./prepare_dev.sh."
		if ! ./prepare_dev.sh >/dev/null 2>&1; then
			echo ""
			echo "Dang!"
			echo "Setup completed with errors."
		else
			echo ""
			echo "Setup complete."
		fi
	} &

}

main "$@"
