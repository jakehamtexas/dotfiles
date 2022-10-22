#!/usr/bin/env bash

tmp_dir='/tmp/qnr-server-tmux'
_ensure_tmp_dir() {
  mkdir -p $tmp_dir
}

# $1 - filename
# $2 - content
tmp_file_write() {
  filename=$1
  content=$2

  _ensure_tmp_dir
  echo $content > $tmp_dir/$filename
}

tmp_file_read() {
  filename=$1

  _ensure_tmp_dir
  cat $tmp_dir/$filename
}

clear_tmp_dir() {
  rm -rf $tmp_dir
}

write_linear_issue() {
  tmp_file_write 'linear-issue' $1
}

readonly session_name_filename='session-name'
read_session_name() {
  tmp_file_read $session_name_filename
}

prompt_session_name() {
  read -p 'name?' -r

  if $(tmux has -t $REPLY >/dev/null 2>&1); then
    echo "Session already exists, choose another name."

    prompt_session_name
    return
  fi

  tmp_file_write $session_name_filename $REPLY
}
