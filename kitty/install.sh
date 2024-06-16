#!/usr/bin/env bash

# Install/update kitty
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

# Generate the next default.conf so that it's easy to see new stuff
THIS_DIR="$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)"
kitty +runpy "from kitty.config import commented_out_default_config as conf; print(conf());" >"$THIS_DIR"/default.conf
