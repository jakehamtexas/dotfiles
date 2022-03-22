#!/bin/bash
xcode-select --install
brew install --HEAD tree-sitter
brew install --HEAD luajit
brew install --HEAD neovim

# Install Packer
./install-packer.sh
