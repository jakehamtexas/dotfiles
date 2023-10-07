#!/usr/bin/env bash

cur_dir="$(dirname "$BASH_SOURCE")"

. "$cur_dir"/lib.sh
. "$cur_dir"/const.sh

_local_branch_name() {
  git branch -av |
    sed 's/[+*]//' |
    awk '{ print $1 }' |
    sed -r 's/remotes\/(.*\/){1}(.*)/\2/' |
    grep --fixed-strings "$1" |
    head -n1
}

# [$1, $2, $3] - [kind: 'global', key, [value]]
# [$1, $2, $3, $4, $5] - [kind: 'branch', branch_name, repo_name, key, [value]]
# [$1, $2, $3, $4] - [kind: 'repo', repo_name, key, [value]]
_set_config() {
  local json
  json=$(_getset_at_path set "$@")

  local kind
  kind="$1"

  shift
  case "$kind" in
  global)
    key=$1
    value=$2
    ;;
  branch)
    branch_name=$1
    repo_name=$2
    key=$3
    value=$4
    ;;
  repo)
    repo_name=$1
    key=$2
    value=$3
    ;;
  esac

  key=$(echo "$CONFIG_KEY_NAMES" | tr ' ' '\n' | grep "^$key\$")

  if [ -z "$key" ]; then
    echo "Unrecognized key $1"
    return 1
  fi

  if [ -z "$value" ]; then
    case "$key" in
    assignee)
      # TODO: fzf reviewers + @me
      ;;
    reviewers)
      # TODO: fzf reviewers
      ;;
    base)
      # TODO: fzf branches, excluding current if known
      ;;
    title | body)
      # TODO: open $EDITOR etc and save result to $value
      # TODO: Select template?
      ;;
    remote)
      # TODO: fzf remotes
      ;;
    esac
  fi

  if [ -z "$value" ]; then
    echo "Invalid empty value"
    return 1
  fi

  if [ "$key" = base ] && [ -z "$(_local_branch_name "$value")" ]; then
    echo "Invalid base branch: $value"
    return 1
  fi

  tmp_filename=$(mktemp)
  echo "$json" >"$tmp_filename"
  mv "$tmp_filename" "$CONFIG_FILE"

  case "$kind" in
  global)
    pr config global
    ;;
  branch | repo)
    pr config "$repo_name" "$branch_name"
    ;;
  esac
}

# [$1] - [kind: 'global']
# [$1, $2, $3] - [kind: 'branch', branch_name, repo_name]
# [$1, $2, $3] - [kind: 'branch-with-inherited', branch_name, repo_name]
# [$1, $2] - [kind: 'repo', repo_name]
# [$1, $2] - [kind: 'repo-with-inherited', repo_name]
_show_config() {
  local branch_name=
  local repo_name=
  case $1 in
  branch | branch-with-inherited)
    shift
    branch_name=$1
    repo_name=$2
    ;;
  repo | global | repo-with-inherited)
    shift
    repo_name=$1
    ;;
  esac

  # TODO: Implement -with-inherited

  local tmp_filename
  tmp_filename=$(mktemp)
  echo "{}" >"$tmp_filename"

  for k in $CONFIG_KEY_NAMES; do
    local branch_value
    branch_value=$(_getset_at_path get branch "$branch_name" "$repo_name" "$k")
    local repo_value
    repo_value=$(_getset_at_path get repo "$repo_name" "$k")
    local global_value
    global_value=$(_getset_at_path get global "$k")

    local loop_tmp_filename
    loop_tmp_filename=$(mktemp)
    jq \
      --argjson branch_value "$branch_value" \
      --argjson repo_value "$repo_value" \
      --argjson global_value "$global_value" \
      --arg key "$k" \
      '.[$key] = ($branch_value // $repo_value // $global_value)' \
      "$tmp_filename" >"$loop_tmp_filename"
    mv "$loop_tmp_filename" "$tmp_filename"
  done
  jq '.' "$tmp_filename"
}

# [$1, $2] - [kind: 'global', key]
# [$1, $2, $3, $4] - [kind: 'branch', branch_name, repo_name, key]
# [$1, $2, $3] - [kind: 'repo', repo_name, key]
_from_config() {
  local key
  case $1 in
  global)
    key=$2
    ;;
  branch)
    key=$4
    ;;
  repo)
    key=$3
    ;;
  esac
  _show_config "$@" | jq -r --arg k "$key" 'getpath([$k])'
}

# [$1, $2, $3, $4] - [get|set, kind: 'global', key, [value]]
# [$1, $2, $3, $4, $5, $6] - [get|set, kind: 'branch', branch_name, repo_name, key, [value]]
# [$1, $2, $3, $4, $5] - [get|set, kind: 'repo', repo_name, key, [value]]
_getset_at_path() {
  local getset
  local kind
  local path
  local key
  local branch_name
  local repo_name

  getset=$1
  kind=$2
  shift
  shift

  case "$kind" in
  global)
    key=$1
    value=$2
    path='["global", $k]'
    ;;
  branch)
    branch_name=$1
    repo_name=$2
    key=$3
    value=$4
    path='[$repo, "branches", $branch, $k]'
    ;;
  repo)
    repo_name=$1
    key=$2
    value=$3
    path='[$repo, $k]'
    ;;
  esac

  local filter
  case $getset in
  get)
    filter='getpath('"$path"')'
    ##
    ;;
  set)
    filter='setpath('"$path"'; $v)'
    ##
    ;;
  esac

  jq \
    --arg repo "$repo_name" \
    --arg branch "$branch_name" \
    --arg k "$key" \
    --arg v "$value" \
    "$filter" \
    "$CONFIG_FILE"
}

pr-config() {
  args_len=$#

  if [ $args_len -eq 0 ]; then
    _show_config branch-with-inherited "$(_repo_name)"
    return 0
  fi
  case $1 in
  # TODO: Add an '--inherited' flag
  # TODO: Move this help text to a function
  help | --help)
    echo 'Usage:'
    echo '        pr config help                                                          - Show this help text'
    echo '        pr config --help                                                        - Show this help text'
    echo ''
    echo '        pr config                                                               - Show resolved JSON for current branch, including the source of inherited config.'
    echo '        pr config branch                                                        - Show resolved config JSON for current branch.'
    echo '        pr config global                                                        - Show global config JSON.'
    echo '        pr config REPO_NAME                                                     - Show resolved config for given repo, including the source of inherited config.'
    echo '        pr config BRANCH_NAME                                                   - Show resolved config JSON for given branch.'
    echo '        pr config REPO_NAME BRANCH_NAME                                         - Show resolved config JSON for given branch in given repo.'
    echo ''
    echo '        pr config set KEY [VALUE]                                               - Set config value for current directory repo.'
    echo '        pr config get KEY                                                       - Get config value for current directory repo.'
    echo ''
    echo '        pr config branch set KEY [VALUE]                                        - Set config value for current branch.'
    echo '        pr config branch get KEY                                                - Get config value for current branch.'
    echo ''
    echo '        pr config <global|REPO_NAME|BRANCH_NAME> [BRANCH_NAME] set KEY [VALUE]  - Set config value globally, for given repo, or for given branch.'
    echo '        pr config <global|REPO_NAME|BRANCH_NAME> [BRANCH_NAME] get KEY          - Get config value globally, for given repo, or for given branch.'
    echo ''
    echo 'Evaluation precedence:'
    echo '        1. CLI arguments'
    echo '        2. Branch'
    echo '        3. Repo'
    echo '        4. Global'
    echo '        5. Environment variable'
    echo ''
    echo '        If no value is found, the default gh CLI behavior is usually to have you enter them in a TUI if the value is required.'
    echo "        If the value is optional, it's just skipped, and you have a chance to modify it later."
    echo ''
    echo 'Available config:'
    echo ''
    echo 'Legend: <key>     | <value>                                       | ENV_VAR_FALLBACK_IF_NOT_SET=default_or_empty'
    echo ''
    echo '        assignee  |  @me, or GitHub username                      | PR_DEFAULT_ASSIGNEE=@me'
    echo '        reviewers |  comma-delimited string of GitHub usernames   | PR_DEFAULT_REVIEWERS='
    echo '        base      |  branch name                                  | PR_DEFAULT_BASE='
    echo '        title     |  string                                       | PR_DEFAULT_TITLE='
    echo '        body      |  string                                       | PR_DEFAULT_BODY='
    echo '        remote    |  remote name, e.g. origin                     | PR_DEFAULT_REMOTE=origin'
    echo ''
    ;;
  branch)
    local current_branch
    current_branch=$(/usr/bin/git branch --show-current)

    local repo_name
    repo_name=$(_repo_name)

    shift
    args_len=$#
    if [ $args_len -eq 0 ]; then
      _show_config branch "$current_branch" "$repo_name"
      return 0
    fi
    case $1 in
    set)
      shift
      pr config "$current_branch" "$repo_name" set "$1" "$2"
      return 0
      ;;
    get)
      shift
      pr config "$current_branch" "$repo_name" get "$1"
      return 0
      ;;
    *)
      # TODO: Display help text
      return 1
      ;;

    esac
    ;;
  global)
    shift
    args_len=$#
    if [ $args_len -eq 0 ]; then
      _show_config global
      return 0
    fi
    case $1 in
    set)
      shift
      _set_config global "$1" "$2"
      return 0
      ;;
    get)
      shift
      _from_config global "$1"
      return 0
      ;;
    *)
      # TODO: Display help text
      return 1
      ;;
    esac
    ;;
  set)
    shift
    _set_config repo "$repo_name" "$1" "$2"
    return 0
    ;;
  get)
    shift
    _from_config repo "$repo_name" "$1"
    return 0
    ;;
  *)
    first_pos_branch_name=$(_local_branch_name "$1")
    second_pos_branch_name=$(_local_branch_name "$2")

    current_repo_name="$(_repo_name)"
    if [ -n "$first_pos_branch_name" ] && [ $# -eq 1 ]; then
      _show_config branch "$first_pos_branch_name" "$current_repo_name"
      return 0
    fi

    if [ -n "$first_pos_branch_name" ]; then
      shift
      case "$1" in
      get)
        shift
        pr config get "$first_pos_branch_name" "$current_repo_name" "$1"
        return 0
        ;;
      set)
        shift
        pr config set "$first_pos_branch_name" "$current_repo_name" "$1" "$2"
        return 0
        ;;
      *)
        # TODO: Show help text
        return 1
        ;;
      esac
    fi

    # TODO: Cache
    repo_name=$(gh repo list --json 'nameWithOwner' | jq -r '.[].nameWithOwner' | grep --fixed-strings "$1")
    shift

    if [ -n "$repo_name" ] && [ $# -eq 0 ]; then
      _show_config repo-with-inherited "$repo_name"
      return 0
    fi

    if [ -n "$repo_name" ] && [ -n "$second_pos_branch_name" ] && [ $# -eq 1 ]; then
      _show_config branch "$second_pos_branch_name" "$repo_name"
      return 0
    fi

    if [ -n "$repo_name" ] && [ -z "$second_pos_branch_name" ] && [ $# -gt 1 ]; then
      case $1 in
      get)
        shift
        _getset_at_path repo "$repo_name" "$1"
        return 0
        ;;
      set)
        shift
        _set_config repo "$repo_name" "$1" "$2"
        return 0
        ;;
      *)
        # Unrecognized command
        # TODO: Show help text
        return 1
        ;;
      esac
    fi

    if [ -n "$repo_name" ] && [ -n "$second_pos_branch_name" ] && [ $# -gt 1 ]; then
      shift
      case $1 in
      get)
        shift
        _getset_at_path branch "$second_pos_branch_name" "$repo_name" "$1"
        return 0
        ;;
      set)
        shift
        _set_config branch "$second_pos_branch_name" "$repo_name" "$1" "$2"
        return 0
        ;;
      *)
        # Unrecognized command
        # TODO: Show help text
        return 1
        ;;
      esac
    fi
    ;;
  esac
}
