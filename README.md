# Instructions

1. Install Nvim using either `install-nvim-mac.sh` or `install-nvim-nightly.sh` for Debian distros
2. Run `setup-symlinks.sh` to symlink `.zshrc` and `init.vim`.
3. Run `install-vim-plug.sh` to install `vim-plug` and all the plugins.
4. Install `zsh` if you want it, with `oh-my-zsh`. If you already have it installed, use `exec zsh` to reload your terminal.


```sh
sh install-nvim-mac.sh && sh setup-symlinks.sh && sh install-vim-plug.sh && exec zsh
