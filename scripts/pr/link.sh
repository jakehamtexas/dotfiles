#!/usr/bin/env bash

pr-link() {
    url=$(gh pr view --json url -q '.url')
    echo "$url" | pbcopy
    echo "$url"
}

pr-link
