#!/usr/bin/env bash

pr-branch() {
  branch=$(git branch --show-current)
  echo "$branch" | pbcopy
  echo "$branch"
}

pr-branch
