#!/usr/bin/env bash

set -e

# This script uses 'fzf' to select a PR from the list of PRs in the current GitHub repo.
# It then checks out the PR locally and opens "$EDITOR".

repo=$1
dir=$2

setup_project() {
	if [ ! -f ./prepare_dev.sh ]; then
		echo "Not in a monorepo workspace."
		exit 1
	fi

	if [ -f "${CYPRESS_SECRETS_PATH:?}" ]; then
		echo "Copying cypress secrets from $CYPRESS_SECRETS_PATH."
		cp "$CYPRESS_SECRETS_PATH" ./apps/cypress/ || echo "Done (already copied)"
	fi

	sudo doppler setup || echo "Skipping setup"

	{
		./prepare_dev.sh >/dev/null 2>&1 && yarn run dev
	} &
}

pick_pr() {
	local pr_number
	if pr_number=$(gh pr list --limit 100 --repo "$repo" |
		fzf --header="Select a PR" |
		awk '{print $1 }'); then
		cd "$dir" || exit
		gh pr checkout "$pr_number"
		gh pr view "$pr_number" -w
	fi
}

pick_pr
setup_project
${EDITOR:?} "$dir"
