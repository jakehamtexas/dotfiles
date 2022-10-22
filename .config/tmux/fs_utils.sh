#!/usr/bin/env bash

readonly tmp_dir=/tmp/$1
_ensure_tmp_dir() {
  mkdir -p $tmp_dir
}

# $1 - filename
# $2 - content
tmp_file_write() {
  readonly filename=$1
  readonly content=$2

  _ensure_tmp_dir
  echo $content > $tmp_dir/$filename
}

tmp_file_read() {
  readonly filename=$1

  _ensure_tmp_dir
  cat $tmp_dir/$filename
}

clear_tmp_dir() {
  rm -rf $tmp_dir
}

readonly session_name_filename='session-name'
read_session_name() {
  tmp_file_read $session_name_filename
}

write_session_name() {
  tmp_file_write $session_name_filename $1
}

prompt_session_name() {
  read -p 'Session name?' -r

  if $(tmux has -t $REPLY >/dev/null 2>&1); then
    echo "Session already exists, choose another name."

    prompt_session_name
    return
  fi

  write_session_name $REPLY
}
