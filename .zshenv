# JAKE CONFIG/ALIASES
export LANG=en_US.UTF-8
export PURE_POWER_MODE=modern
export POWERLEVEL9K_MODE='nerdfont-complete'
export NVIM_DIR=$HOME/.config/nvim
export GPG_TTY=$(tty)
export EDITOR=$(which nvim)

export TMUX_DIR=$HOME/.config/tmux
export TMUX_TPM_DIR_PATH=$TMUX_DIR/plugins/tpm

if [ -n $TMUX ]; then
  tmux setenv TMUX_DIR $TMUX_DIR
  tmux setenv TMUX_TPM_DIR_PATH $TMUX_TPM_DIR_PATH
fi

alias npm-what=npm pack && tar -xvzf *.tgz && rm -rf package *.tgz
alias ssh-pi="ssh pi@raspberrypi.local"
alias vim="nvim"
alias grep="rg"
alias printdoc=lpr
alias pacman='sudo pacman'
alias shutdown='sudo shutdown'
alias reboot='sudo reboot'

#!/usr/bin/env bash

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

git config --global alias.r '!f(){ git rebase $($HOME/scripts/git_upstream_branch.sh $1); }; f'
git config --global alias.ri '!f(){ git rebase -i $($HOME/scripts/git_upstream_branch.sh $1); }; f'
git config --global alias.rc 'rebase --continue'

git config --global alias.wa 'worktree add'
git config --global alias.wr 'worktree remove'
git config --global alias.wrf 'worktree remove --force'
git config --global alias.wrp 'worktree prune'

git config --global alias.bsc 'branch --show-current'

git config --global alias.aliases "! git config --get-regexp '^alias\.' | cat"

test -f "$HOME/.cargo/env" && . "$HOME/.cargo/env"

. $HOME/dotfiles.alias

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


handle_home_dir () {
  if [ "$PWD" = "$HOME" ]; then
    export GIT_DIR=$DOTFILES_GIT_DIR
    export GIT_WORK_TREE=$HOME
  else
    unset GIT_DIR
    unset GIT_WORK_TREE
  fi
}

with_unset_git_env() {
  readonly git_dir=$GIT_DIR
  readonly git_wt=$GIT_WORK_TREE

  unset GIT_DIR
  unset GIT_WORK_TREE

  $@ || true
  
  export GIT_DIR=$git_dir
  export GIT_WORK_TREE=$git_wt
}

alias yay='with_unset_git_env yay'

_dotfiles_head() {
  dotfiles rev-parse HEAD
}

_dotfiles_origin_main() {
  cat $DOTFILES_ORIGIN_MAIN_REV_CACHE_PATH
}


_can_check () {
  readonly last_check_epoch_seconds=$(cat $DOTFILES_LAST_REMOTE_CHECK_TIME_PATH 2>/dev/null || echo 0)

  readonly now_seconds=$(date +%s)
  readonly min_seconds=
  if [ $now_seconds -gt $(($last_check_epoch_seconds + 60*60)) ]; then
    return 0
  fi

  return 1
}

_check_for_new_dotfiles_revision () {
  dotfiles fetch >/dev/null 2>&1
  mkdir -p $DOTFILES_STATE

  readonly main_rev_cache=$(cat $DOTFILES_GIT_DIR/FETCH_HEAD | awk '{print $1}')
  echo $main_rev_cache > $DOTFILES_ORIGIN_MAIN_REV_CACHE_PATH

  readonly now_seconds=$(date +%s)
  echo $now_seconds > $DOTFILES_LAST_REMOTE_CHECK_TIME_PATH

  readonly num_ahead=$(dotfiles rev-list $(_dotfiles_head)..$(_dotfiles_origin_main) --count)

  if [[ $num_ahead -eq 0 ]]; then
    return
  fi

  echo ''
  echo 'New changes in upstream dotfiles!'
  echo 'Use function "dotfiles_diff" to see them.'
  echo ''
}

dotfiles_diff() {
  dotfiles diff $(_dotfiles_head) $(_dotfiles_origin_main)
}

chpwd () {
  handle_home_dir
  _can_check && _check_for_new_dotfiles_revision
}

# SAFEBASE CONFIG/ALIASES
export VIM_LOCAL_CONFIG_DIR_PATH="$HOME/.sb-local-vim"
export CYPRESS_SECRETS_PATH="$HOME/cypress.env.json"

alias arm64bi='arch -arm64 brew install'
alias setup="$HOME/scripts/prepare_dev.sh &"

alias yr='yarn run'
alias yrd='yr dev'
alias yrtc='yr g:type-check'
alias yrg='yarn && yr generate' # The most often needed part of prepare dev when rebasing
alias yrpp='yr g:pre-push'
alias sbpd=./prepare_dev.sh

alias zshrc='vim $HOME/.zshrc'

pr () {
  case $1 in
    view)
      gh pr view --web
      ;;
    link)
      url=$(gh pr view --json url -q '.url')
      echo $url | pbcopy
      echo "Copied url!"
      echo $url
      ;;
    branch)
      branch=$(gh pr view --json headRefName -q '.headRefName')
      echo $branch | pbcopy
      echo "Copied branch!"
      echo $branch
      ;;
    *)
    echo 'Usage:'
    echo '        pr view   -- open PR in web browser'
    echo '        pr link   -- copies current PR link to clipboard with pbcopy'
    echo '        pr branch -- copies current PR branch name to clipboard with pbcopy'
      ;;
  esac
}
