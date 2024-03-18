#! /usr/bin/env bash

while read -r id; do
	tmux send-keys -t "$id" ':wa | qa' Enter
	sleep 0.5
	tmux send-keys -t "$id" 'vim' Enter
done <<<"$(tmux list-window -a -F '#D #{pane_current_command}' | grep nvim | cut -d' ' -f1)"
