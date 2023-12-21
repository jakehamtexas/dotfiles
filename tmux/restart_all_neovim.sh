#! /usr/bin/env bash

nvim_processes=$(ps | grep nvim | cut -d' ' -f1 -f2)

while read -r tty id; do
  if echo "$nvim_processes" | grep -q "${tty//\/dev\//}"; then
    echo "$id"
    tmux send-keys -t "$id" ':wa | qa' Enter
    sleep 0.5
    tmux send-keys -t "$id" 'vim' Enter
  fi
done <<<"$(tmux list-windows -a -F '#{pane_tty} #{session_name}:#{window_index}.#{pane_index}')"
