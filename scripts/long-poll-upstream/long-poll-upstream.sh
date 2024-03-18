#!/usr/bin/env bash
thiscommand=$(basename "$0")

if [ $# -lt 2 ]; then
	echo "Usage: $thiscommand [-f] POST-PULL-SCRIPT [BRANCH=\$(git rev-parse --abbrev-ref HEAD)] [INTERVAL=\"0 8-17 * * 1-5\"]"
	echo ""
	echo "Register a long poll CRON interval to $(git-pull) BRANCH and execute POST-PULL-SCRIPT."
	echo "POST-PULL-SCRIPT must be a bash script."
	echo "Must be run inside a worktree (either the primary from $(git-clone) or another via $(git-worktree))."
	echo ""
	echo "If updating an existing script, use the -f force flag."
	echo ""
	exit 1
fi

LPU_DIR="$HOME/.config/.lpu"

mkdir -p "$LPU_DIR"

if [[ $(git rev-parse --is-inside-work-tree) != true ]]; then
	echo "Must be run inside a worktree (either the primary from $(git-clone) or another via $(git-worktree))."
	exit 1
fi

if [[ $1 = -f ]]; then
	force_flag=$1
	post_pull_script=$2
	branch=${3:-$(git rev-parse --abbrev-ref HEAD)}
	interval=${4:-"0 8-17 * * 1-5"}
else
	post_pull_script=$1
	branch=${2:-$(git rev-parse --abbrev-ref HEAD)}
	interval=${3:-"0 8-17 * * 1-5"}
fi

if [[ -z $post_pull_script ]]; then
	echo "Must specify POST-PULL-SCRIPT."
	exit 1
fi

repo_name=$(basename -s .git "$(git config --get remote.origin.url)")
script_id="$repo_name-$branch-$post_pull_script"

if test -f "$LPU_DIR/$script_id"; then
	echo "Existing script detected."
	if [[ -z $force_flag ]]; then
		echo "When updating an existing script, use the \`-f\` force flag."
		exit 1
	fi
fi

dir=$(pwd)

$(which bash) ./make-script.sh "$dir" "$script_id" "$interval"
