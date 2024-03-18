#!/usr/bin/env bash

readonly tmp_dir=/tmp/$1
_ensure_tmp_dir() {
	mkdir -p "$tmp_dir"
}

# $1 - filename
# $2 - content
tmp_file_write() {
	local filename=$1
	local content=$2

	_ensure_tmp_dir
	echo "$content" >"$tmp_dir/$filename"
}

tmp_file_read() {
	local filename=$1

	_ensure_tmp_dir
	cat "$tmp_dir/$filename"
}

clear_tmp_dir() {
	rm -rf "$tmp_dir"
}

readonly session_name_filename='session-name'
read_session_name() {
	tmp_file_read "$session_name_filename"
}

write_session_name() {
	tmp_file_write "$session_name_filename" "$1"
}

prompt_session_name() {
	if [ -n "$1" ]; then
		read -p "Session name (Default: $1)?" -r session_name
		session_name=${session_name:-$1}
	else
		read -p 'Session name?' -r session_name
	fi

	if tmux has -t "$session_name" >/dev/null 2>&1; then
		echo "Session already exists, choose another name."

		prompt_session_name "$@"
		return
	fi

	write_session_name "$session_name"
}

readonly window_name_filename='window-name'
read_window_name() {
	tmp_file_read "$window_name_filename"
}

write_window_name() {
	tmp_file_write "$window_name_filename" "$1"
}

clear_tmp_dir
