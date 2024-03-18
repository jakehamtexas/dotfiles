#!/usr/bin/env bash

# Get script dir
cur_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$cur_dir"/view.sh
. "$cur_dir"/link.sh
. "$cur_dir"/branch.sh
. "$cur_dir"/config.sh
. "$cur_dir"/reviewers.sh

. "$cur_dir"/lib.sh
. "$cur_dir"/const.sh

# TODO: Refactor and break apart to other files

pr() {
	command=$1
	shift
	case $command in
	view)
		pr-view "$@"
		;;
	link)
		pr-link "$@"
		;;
	branch)
		pr-branch "$@"
		;;
	config)
		pr-config "$@"
		;;
	reviewers)
		pr-reviewers "$@"
		;;
	create)
		pr-create "$@"
		;;
	*)
		echo 'Usage:'
		echo '        pr view   -- open PR in web browser'
		echo '        pr link   -- copies current PR link to clipboard with pbcopy'
		echo '        pr branch -- copies current PR branch name to clipboard with pbcopy'
		echo '        pr create -- creates a PR with gh arguments'
		;;
	esac
}

_initialize_empty_config_if_not_exists

! test -f "$REVIEWERS_FILE" && pr reviewers update

pr "$@"
