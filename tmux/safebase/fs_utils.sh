#!/usr/bin/env bash

. $TMUX_DIR/fs_utils.sh 'qnr-server-tmux'

write_linear_issue() {
  tmp_file_write 'linear-issue' $1
}
