$!/usr/bin/env bash

. "$cur_dir"/lib.sh
. "$cur_dir"/const.sh

pr-reviewers() {
  case $1 in
  show)
    jq '.' "$REVIEWERS_FILE"
    ;;
  fetch)
    shift

    owner_name=${1-$(_current_repo_owner)}

    assignable_users=$(_jqable_repo_info list "$owner_name")

    tmp_filename=$(mktemp)
    jq \
      --arg rname "$repo_name" \
      --argjson users "$assignable_users" \
      -j \
      '.[$rname] = $users' "$REVIEWERS_FILE" \
      >"$tmp_filename"
    mv "$tmp_filename" "$REVIEWERS_FILE"
    ;;
  help | --help)
    echo 'Usage:'
    echo '        pr reviewers help               - Show this help text'
    echo '        pr reviewers --help             - Show this help text'
    echo ''
    echo '        pr reviewers                                         '
    echo '        pr reviewers show               - Show reviewers JSON'
    echo ''
    echo '        pr reviewers fetch              - Update the reviewers list from GitHub for the current owner.'
    echo '        pr reviewers fetch OWNER_NAME   - Update the reviewers list from GitHub for the given owner'
    ;;
  *)
    jq '.' "$REVIEWERS_FILE"
    ;;
  esac
}
