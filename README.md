# Instructions

This dotfiles repo is set up to follow the article given by [Gabrielle Young for ackama.com][1].

## Cloning and Installing

Use the following script to correctly clone the bare repo.

```sh
wget -O - https://raw.githubusercontent.com/jakehamtexas/dotfiles/main/scripts/clone.sh | sh
```

Next, restart the shell and use `checkout` to "install" the home directory.

```sh
exec zsh
dotfiles checkout
```

## Usage

In `dotfiles.alias` (which is sourced in `.zshrc` and by the clone script above), a shell variable is exported
that is called `$DOTFILES_GIT_DIR`. It enables the usage of the `~/.dotfiles-git` dir as the bare git directory
git dir.

There is also an alias for `dotfiles` that is sourced in `dotfiles.alias`. It aliases the `git` command in the `$HOME`
directory. This means that you can manipulate the dotfiles git repo from any directory, as long as the alias is sourced.

e.g.

```sh
dotfiles status
dotfiles add .
dotfiles commit -m "Dotfiles is just Git!"
```

[1]: https://www.ackama.com/what-we-think/the-best-way-to-store-your-dotfiles-a-bare-git-repository-explained/

