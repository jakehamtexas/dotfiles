#!/usr/bin/env bash

set -e -o pipefail

main() {
	local new_dir="$1"
	[ -z "$new_dir" ] && {
		echo 'Usage: worktree-add PATH [new-branch-name] [checkout-from-commit-ish]'
		exit 1
	}

	[[ -d "$new_dir" ]] && {
		echo "Directory exists: $new_dir"
		exit 1
	}

	. "$(cd "$(dirname "$0")" && pwd)/lib.sh"
	. "$(cd "$(dirname "$0")" && pwd)/env.sh"

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
	base_commit_ish="${3:-"$(fzf_branches || echo "")"}"

	git fetch

	echo "new_dir: $new_dir"
	echo "branch_to_checkout: $branch_to_checkout"
	echo "base_commit_ish: $base_commit_ish"

	if [ -z "$branch_to_checkout" ]; then
		if [ -z "$base_commit_ish" ]; then
			git worktree add --detach "$new_dir" main
		else
			git worktree add "$new_dir" "$base_commit_ish"
		fi
	else
		git worktree add -b "$branch_to_checkout" "$new_dir" "$base_commit_ish"
	fi

	local new_dir="$1"
	local issues="$2"
	local id="$3"

	cd "$new_dir"

	mkdir .vim
	if [ -n "$issues" ] && [ -n "$id" ]; then
		find_issue "$issues" "$id" >.vim/issue.json
	fi

	touch "${SHOULD_INIT_FILENAME:?}"
}

main "$@"
