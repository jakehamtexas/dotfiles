# JAKE CONFIG/ALIASES
export LANG=en_US.UTF-8
export PURE_POWER_MODE=modern
export POWERLEVEL9K_MODE='nerdfont-complete'
export NVIM_DIR=$HOME/.config/nvim
export GPG_TTY=$(tty)
export EDITOR=$(which nvim)

alias npm-what=npm pack && tar -xvzf *.tgz && rm -rf package *.tgz
alias ssh-pi="ssh -i $HOME/.ssh/rpi_ecdsa pi@192.168.0.6"
alias vim="nvim"
alias grep="rg"
alias printdoc=lpr
alias pacman='sudo pacman'
alias shutdown='sudo shutdown'
alias reboot='sudo reboot'

git config --global core.editor "$(which nvim)"
git config --global pull.rebase true
git config --global init.defaultBranch main
git config --global user.email 'jakehamtexas@gmail.com'
git config --global user.name 'Jake Hamilton'
git config --global fetch.prune true
git config --global push.autoSetupRemote true

git config --global alias.a add
git config --global alias.aa 'add .'
git config --global alias.ap 'add -p'

git config --global alias.co "!sh $HOME/scripts/fzf_git_checkout.sh"

git config --global alias.c commit
git config --global alias.ca 'commit -a'
git config --global alias.cp 'commit -p'
git config --global alias.cam 'commit -a -m'
git config --global alias.cpm 'commit -p -m'
git config --global alias.caa 'commit -a --amend'
git config --global alias.caam 'commit -a --amend -m'
git config --global alias.can 'commit --amend --no-edit'
git config --global alias.cpan 'commit -p --amend --no-edit'
git config --global alias.caan 'commit -a --amend --no-edit'

git config --global alias.fp 'push -u --force-with-lease'
git config --global alias.fpp '!f(){ git fp --no-verify; }; f'
git config --global alias.fpg '!f(){ git fp --no-verify && yarn && yarn run generate; git push; }; f'

git config --global alias.r '!f(){ git rebase $($HOME/scripts/git_upstream_branch.sh $1); }; f'
git config --global alias.ri '!f(){ git rebase -i $($HOME/scripts/git_upstream_branch.sh $1); }; f'
git config --global alias.rc 'rebase --continue'

git config --global alias.wa '!sh $HOME/scripts/sb-worktree/add.sh'
git config --global alias.wr 'worktree remove'
git config --global alias.wrf '!f(){ git worktree remove --force $(realpath $1); git worktree prune; }; f'
git config --global alias.wrp 'worktree prune'

git config --global alias.bsc 'branch --show-current'

git config --global alias.aliases "! git config --get-regexp '^alias\.' | cat"

test -f "$HOME/.cargo/env" && . "$HOME/.cargo/env"

. $HOME/dotfiles/dotfiles.alias

_findp () {
  ps aux | rg -v rg | rg $1
}

findp () {
  if [ -z $1 ]; then
    echo "Not enough arguments, must include a search term"
    return 1
  fi

  find_out=$(ps aux | rg -v rg | rg $1)
  if [ -z $find_out ]; then
    echo "Nothing found when searching: '$1'"
    return 1
  fi

  echo $find_out
}

killp () {
  if [ -z $1 ]; then
    echo "Not enough arguments, must include a search term"
    return 1
  fi

  find_out=$(_findp $1)
  if [ -z $find_out ]; then
    echo "Nothing found when searching: '$1'"
    return 1
  fi

  echo $find_out

  choice=
  vared -p 'Kill these? [Y/n]' choice

  if [[ $choice =~ ^[Yy]$ ]]; then
    echo $find_out | awk '{ print $2 }' | sudo xargs kill
    return
  fi 

  return 1
}

export DOTFILES_STATE=/tmp/dotfiles
export DOTFILES_ORIGIN_MAIN_REV_CACHE_PATH=$DOTFILES_STATE/main_rev_cache
export DOTFILES_LAST_REMOTE_CHECK_TIME_PATH=$DOTFILES_STATE/last_remote_check_time


handle_new_worktree() {
  if [ -f ./worktree_should_init ]; then
    rm ./worktree_should_init 

    "$HOME/scripts/prepare_dev.sh"
    nvim
  fi
}

chpwd () {
  handle_new_worktree

  nvm use stable
}

gh_path="$(which gh)"

gh() {
  if ! command -v "$gh_path" >/dev/null 2>&1; then
    echo "gh not installed"
    return 1
  fi

  if [[ "$1" == "pr" && "$2" == "create" ]]; then
    git push -u origin HEAD
  fi

  "$gh_path" $@
}

# SAFEBASE CONFIG/ALIASES
export VIM_LOCAL_CONFIG_DIR_PATH="$HOME/.sb-local-vim"
export CYPRESS_SECRETS_PATH="$HOME/cypress.env.json"

alias arm64bi='arch -arm64 brew install'
alias setup="$HOME/scripts/prepare_dev.sh"

alias yr='yarn run'
alias yrd='yr dev'
alias yrtc='yr g:type-check'
alias yrg='yarn && yr generate' # The most often needed part of prepare dev when rebasing
alias yrpp='yr g:pre-push'
alias sbpd=./prepare_dev.sh

alias zshrc='vim $HOME/.zshrc'

alias pr="$HOME/scripts/pr/pr.sh"
alias review="$HOME/scripts/clone-review.sh"

. "$HOME"/scripts/git.sh
