#!/usr/bin/env bash

if ! yay -Q nix; then
	yay nix
fi

user="${USER:-$(who | head -n1 | awk '{print $1}')}"

if ! groups "$user" | grep -q nix-users; then
	sudo gpasswd -a "$user" nix-users

	su - "$user"
fi

echo "Starting nix-daemon"
if ! systemctl | grep -q nix-daemon.service &&
	! sudo systemctl enable --now nix-daemon.service; then
	echo "Reboot and run this script again"
	exit 1
fi

echo "Adding nix-channels"
nix-channel --add https://nixos.org/channels/nixpkgs-unstable
nix-channel --update
