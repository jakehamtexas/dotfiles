#!/usr/bin/env bash

# [list | view]
# [owner | repo]
_jqable_repo_info() {
  gh repo "$1" "$2" --json 'nameWithOwner,assignableUsers'
}

_repo_name() {
  _jqable_repo_info | jq '.nameWithOwner' -r
}

_empty_config() {
  jq --null-input \
    --arg assignee "@me" \
    --argjson reviewers null \
    --argjson base null \
    --argjson title null \
    --argjson body null \
    --arg remote "origin" \
    '{ "global": { "assignee": $assignee, "reviewers": $reviewers, "base": $base, "title": $title, "body": $body, "remote": $remote } }'
}

_initialize_empty_config_if_not_exists() {
  empty_config=$(_empty_config)

  if [ ! -f "$CONFIG_FILE" ]; then
    echo "$empty_config" >"$CONFIG_FILE"
  fi
}

_current_repo_owner() {
  gh repo view --json owner | jq -r '.owner.login'
}
