#!/bin/bash

# What to do when we enter the dir

sudo doppler setup

# What to do when we have just created the dir
nvm use
yarn >/dev/null || true
yarn run generate >/dev/null || true
