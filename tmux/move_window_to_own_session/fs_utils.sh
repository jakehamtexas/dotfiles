#!/usr/bin/env bash

. "${TMUX_DIR:?}"/fs_utils.sh 'move-window-to-own-session'

readonly window_id_filename='window_id'
read_window_id() {
	tmp_file_read "$window_id_filename"
}

write_window_id() {
	tmp_file_write "$window_id_filename" "$1"
}
