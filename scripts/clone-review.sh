#!/usr/bin/env bash

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
"$script_dir"/gh-clone.sh \
	--post="$script_dir"/post.sh \
	--tmp \
	git@sb:safebaselabs/qnr-server.git
