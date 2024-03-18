#!/usr/bin/env bash

cur_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$cur_dir"/lib.sh
. "$cur_dir"/const.sh

_me_username() {
	gh_auth_status="$(gh auth status 2>&1)"
	echo "$gh_auth_status" | sed -nr 's/.*Logged in to github\.com as ([a-zA-Z0-9\-_!@#$%&*()]+).*/\1/p' | xargs
}

pr-create() {
	has_reviewer=n
	for arg in "$@"; do
		[ "$arg" = '-r' ] && has_reviewer=y
	done

	if [ "$has_reviewer" = n ]; then
		me=$(_me_username)

		if ! found=$(jq \
			-r \
			--arg repo "_repo_name" \
			--arg me "$me" \
			'.[$repo] | .[] | select(.login | contains($me) | not) | "\(.login), name: \(.name)"' \
			"$REVIEWERS_FILE" |
			fzf -m); then
			return 1
		fi

		for r in $(echo "$found" | awk '{ print $1 }' | sed 's/,//g' | xargs); do
			selected_reviewers="${selected_reviewers} -r $r"
		done
	fi

	gh pr create -a "@me" "$@" "$selected_reviewers"
}
