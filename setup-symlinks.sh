#!/bin/bash
cd ~
mkdir -p .config/nvim
cd .config/nvim
rm init.vim
ln -s ~/dotfiles/init.vim init.vim

cd ~
rm .zshrc
ln -s ~/dotfiles/.zshrc .zshrc
