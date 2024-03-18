#!/usr/bin/env bash

dir=$1
script_id=$2
interval=$3

branch=$(echo "$script_id" | cut -d'-' -f2)
script=$(echo "$script_id" | cut -d'-' -f3)

# Execute script by wrapping it in another script which does the following:
# 1. `cd` to the current directory
# 2. Exit early if directory is not on expected `git` branch
# 3. Execute `git pull`
# 4. Execute the script in question, passing the output from `git pull`.
#
# Write this script to a file named by $script_id
cat >"$script_id" <<-EOM

	cd "$dir"

	LOGFILE="$script_id.log"
	function log {
	  # TODO: Does this work?
	  echo '$(date)' >> "${LOGFILE:?}"
	  echo '$1' >> "${LOGFILE:?}"
	}

	current_branch = git rev-parse --abbrev-ref HEAD
	if [[ "${current_branch:?}" -ne "$branch" ]] then
	  log "Branch $current_branch doesn't match $branch, exiting quietly"
	  exit 0
	fi

	output="$(git pull)"
	log "Git pull completed"
	. "$script ${output:?}"
	log "Script run completed"

EOM

# Add this new script as a crontab entry with the specified time
if "$(grep -L "$script_id" /etc/crontab)" || ("$(grep -q "$script_id" /etc/crontab)" && [[ -n $force_flag ]]); then
	echo "$interval $(whoami) bash $script" >>/etc/crontab
fi
