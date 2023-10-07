#!/usr/bin/env bash

# This script wraps 'git clone' and allows options for cloning to a tmp directory and running pre- and
# post-clone hooks.
#
# If the repo is not specified, 'fzf', 'jq', and 'gh' are used to select a repo from
# the list of repos in the current GitHub user's available orgs.
#
# Hooks
# =====
#
# Hooks are specified using the '--pre' and '--post' options.
#
# For example:
#   gh-clone.sh --pre=~/scripts/pre-clone.sh --post=~/scripts/post-clone.sh
#
#
# The pre-clone hook is run before the repo is cloned. The post-clone hook is run after the repo is cloned.
# The script will run the specified hooks with the repo as the FIRST argument and directory as the SECOND argument.
#
# Caching
# =======
#
# When a repo is not specified, the script works by requesting the orgs and repos
# associated with the current user from the GitHub API. The results are cached. The cache
# can be cleared by using the 'clean' command, or by deleting the cache dir,
# which is located at '$HOME/.cache/gh-clone'.
#
# The cache is considered stale after 1 day for repos and 1 week for orgs.
#
# Protocol
# ========
#
# By default, the script will use the SSH protocol to clone repos. This can be overridden
# by using the '--http' option.
#
# If an argument is given for the '--ssh' option, it will be used as the host for the SSH
# protocol. This is useful if you want to use a different host than the default, which is
# 'github.com'.
#
# Example: clone a repo using the SSH protocol, but use a different host:
# gh-clone.sh --ssh=git-at-work <repo>
#
# This will yield a remote URL like this:
# git@git-at-work:owner/repo.git
#
# Compare this to the default, which would be:
# git@github.com:owner/repo.git

# Usage:
#  Repo specified:
#  ./gh-clone.sh [--tmp] [--pre=<script_path>] [--post=<script_path>] repo [-- <gitflags>...]
#  ./gh-clone.sh [--pre=<script_path>] [--post=<script_path>] repo [<directory>] [-- <gitflags>...]
#
#  SSH protocol:
#  ./gh-clone.sh [--tmp] [--pre=<script_path>] [--post=<script_path>] [--ssh=[host]] [-- <gitflags>...]
#  ./gh-clone.sh [--pre=<script_path>] [--post=<script_path>] [--ssh=[host]] [<repo>] [<directory>] [-- <gitflags>...]
#
#  HTTP protocol:
#  ./gh-clone.sh [--tmp] [--pre=<script_path>] [--post=<script_path>] [--http] [-- <gitflags>...]
#  ./gh-clone.sh [--pre=<script_path>] [--post=<script_path>] [--http] [<repo>] [<directory>] [-- <gitflags>...]
#
#  Clean cache:
#  ./gh-clone.sh clean

# Constants
CACHE_DIR="$HOME/.cache/gh-clone"
ONE_DAY="$((60 * 60 * 24))"
ONE_WEEK="$((60 * 60 * 24 * 7))"

# Parse args
clear_cache=""
pre_script=""
post_script=""
use_tmp=""
repo_url=""
directory=""
gitflags=""
use_ssh="true"
ssh_host="github.com"
use_http=""

# TODO: Add support for '--ssh' and '--http' options.

parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
    clean)
      clear_cache="true"
      break
      ;;
    --tmp)
      use_tmp="true"
      shift
      ;;
    --pre=*)
      pre_script="${1#--pre=}"
      shift
      ;;
    --post=*)
      post_script="${1#--post=}"
      shift
      ;;
    --ssh)
      use_ssh="true"
      shift
      ;;
    --ssh=*)
      use_ssh="true"
      ssh_host="${1#--ssh=}"
      shift
      ;;
    --http)
      use_http="true"
      shift
      ;;
    --)
      shift
      gitflags=$*
      break
      ;;
    *)
      if [ -z "$repo" ]; then
        repo_url="$1"
      elif [ -z "$directory" ]; then
        directory="$1"
      fi
      shift
      ;;
    esac
  done
}

debug() {
  if [ -n "$DEBUG" ]; then
    echo "$@" >&2
  fi
}

# Always create this dir so that we don't have to check for its
# existence later.
mkdir -p "$CACHE_DIR" >/dev/null 2>&1

cache_file() {
  name="$1"
  echo "$CACHE_DIR/$name"
}

write_cache_and_echo() {
  debug "$@"

  name="$1"

  # Read the content from stdin, since we are piping it in.
  content="$(cat)"

  timestamp="$(date +%s)"

  file="$(cache_file "$name")"

  debug "Writing cache file: $file"
  echo "$timestamp" >"$file"
  echo "$content" >>"$file"

  echo "$content"
}

read_cache() {
  name="$1"
  ttl="$2"

  file="$(cache_file "$name")"

  if [ ! -f "$file" ]; then
    debug "Cache file not found: $file"
    return 1
  fi

  # If the timestamp on the first line is older than TTL, then
  # the cache is stale.
  timestamp="$(head -n 1 "$file")"
  now="$(date +%s)"

  debug "Cache file timestamp: $timestamp"
  debug "Current timestamp: $now"

  if [ "$((now - timestamp))" -gt "$ttl" ]; then
    debug "Cache file is stale: $file"
    return 1
  fi

  debug "Reading cache file: $file"

  # Skip the first line (timestamp) and echo the rest.
  tail -n +2 "$file"
}

get_orgs() {
  read_cache \
    "orgs" \
    "$ONE_WEEK" ||
    {
      debug "Fetching orgs"
      gh org list --limit 1000 | write_cache_and_echo "orgs" "$ONE_WEEK"
    }
}

# Get all of the repos for every org that belongs to the current user.
get_repos() {
  json_fields="id,url,sshUrl,nameWithOwner"
  read_cache \
    "repos" \
    "$ONE_DAY" || {
    debug "Fetching repos"
    org_repos="$(get_orgs | while read -r org; do
      gh repo list "$org" --limit 1000 --json "$json_fields"
    done)"

    user_repos="$(gh repo list --limit 1000 --json "$json_fields")"
    echo "$user_repos" "$org_repos" | write_cache_and_echo "repos" "$ONE_DAY"
  }
}

pick_repo() {
  if ! id="$(get_repos |
    jq -r '.[] | " \(.nameWithOwner) \(.id)"' |
    fzf --header="Select a repo to clone" |
    awk '{print $2}')"; then
    return 1
  fi

  url_property="sshUrl"
  if [ -n "$use_http" ]; then
    url_property="url"
  fi

  url="$(get_repos | jq -r --arg id "$id" ".[] | select(.id == \$id) | .$url_property")"

  # If the URL is SSH, its format follows git@github.com:owner/repo.git.
  # We need to replace the host part with the host specified by the user.
  if [ -n "$use_ssh" ] && [ -n "$url" ]; then
    url="${url%%@*}@$ssh_host:${url#*:}"
  fi

  repo_url="$url"
}

resolve_dir() {
  if [ -n "$use_tmp" ]; then
    dir="$(mktemp -d)"
  else
    dir="${dir:-$(basename "$repo_url")}"
    dir=${dir%%.git}
  fi

  if [ -z "$dir" ]; then
    echo "No directory specified"
    return 1
  fi

  debug "Resolved dir: $dir"
}

resolve_repo_url() {
  if [ -z "$repo_url" ]; then
    pick_repo
  fi

  if [ -z "$repo_url" ]; then
    echo "No repo selected"
    return 1
  fi

  debug "Resolved repo url: $repo_url"
}

get_repo_from_url() {
  # Parse the repo and owner name from the URL.
  # The URL format is:
  # SSH: git@host:owner/repo
  # HTTPS: https://github.com/owner/repo.git

  if [ -n "$use_ssh" ]; then
    repo="${repo_url##*:}"
    repo="${repo%%.*}"
  else
    repo="${repo_url##*/}"
    repo="${repo%%.*}"
  fi
}

find_file() {
  if command -v readlink >/dev/null 2>&1; then
    readlink -f "$1"
    return
  fi
  if command -v greadlink >/dev/null 2>&1; then
    greadlink -f "$1"
    return
  fi
  if command -v realpath >/dev/null 2>&1; then
    realpath "$1"
    return
  fi

  echo "readlink or realpath not found"
  return 1
}

pre_clone() {
  if [ -n "$pre_script" ]; then
    debug "Running pre-clone hook"
    "$(find_file "$pre_script")" "$repo" "$dir"
  fi
}

post_clone() {
  if [ -n "$post_script" ]; then
    debug "Running post-clone hook"
    "$(find_file "$post_script")" "$repo" "$dir"
  fi
}

clone() {
  debug "Cloning $repo to $dir"

  if [ -n "$gitflags" ]; then
    git clone "$repo_url" "$dir" "$gitflags"
  else
    git clone "$repo_url" "$dir"
  fi
}

main() {
  parse_args "$@"

  if [ -n "$clear_cache" ]; then
    debug "Clearing cache"
    rm -rf "$CACHE_DIR"
    return
  fi

  if resolve_repo_url && resolve_dir && get_repo_from_url; then
    pre_clone
    clone
    post_clone
  fi
}

main "$@"
