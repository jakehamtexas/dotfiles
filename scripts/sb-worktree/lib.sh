#!/usr/bin/env bash

. "$HOME"/scripts/git.sh

# TODO: Rewrite this in lua/python/something not bash

ensure_linear_env() {
	if [ -z "$LINEAR_API_KEY" ]; then
		echo 'missing linear api key'

		exit 1
	fi

	if [ -z "$LINEAR_EMAIL" ]; then
		echo 'missing linear email'

		exit 1
	fi
}

query_issues() {
	curl \
		-X POST \
		-H "Content-Type: application/json" \
		-H "Authorization: $LINEAR_API_KEY" \
		--data '{ "query": "{ issues(filter: { assignee: { email: { eq: \"'"$LINEAR_EMAIL"'\" } } } orderBy: updatedAt) { nodes { title branchName identifier url } } }" }' \
		https://api.linear.app/graphql |
		jq '.data.issues.nodes'
}

fzf_issues() {
	already_checked_out="$(git_branches | xargs | tr '\n' ' ')"
	echo "$1" |
		jq -r \
			--arg alreadyCheckedOut "$already_checked_out" \
			'map(select(.branchName as $branchName | ($alreadyCheckedOut | split(" ") | any(. == $branchName) | not))) | .[] | "\(.identifier): \(.title)"' |
		fzf --header 'Pick a linear issue to checkout' --header-first |
		cut -d ':' -f1
}

find_issue() {
	issues="$1"
	id="$2"

	echo "$issues" | jq \
		--arg id "$id" \
		-r \
		'map(select(.identifier == $id))'
}

find_branch_name() {
	issues="$1"
	id="$2"
	jq -r '.[].branchName' <<<"$(find_issue "$issues" "$id")"
}

fzf_branches() {
	branches="$(git_branches | grep remotes)"
	echo "$branches" |
		fzf --header 'Pick a git branch for your base' --header-first |
		xargs
}
