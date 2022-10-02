# Add rustup completions if they exist
[ -d $HOME/.zfunc ] && fpath+=$HOME/.zfunc

# Path to your oh-my-zsh installation.
ZSH="$HOME/.oh-my-zsh"

if [ ! -d "$ZSH" ]; then
  export KEEP_ZSHRC=yes
  sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
fi


export ZSH="$ZSH"
export ZSH_CUSTOM=$ZSH/custom

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="agnoster"

# Uncomment the following line to automatically update without prompting.
DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

#
# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/

plugins=()

_plugins=(
  git
  docker
  docker-compose
  'MichaelAquilina/zsh-history-filter'
  'zsh-users/zsh-autosuggestions'
  'zsh-users/zsh-syntax-highlighting'
  'marlonrichert/zsh-autocomplete'
  'b4b4r07/enhancd'
  'unixorn/fzf-zsh-plugin'
)
for plugin in "${_plugins[@]}"; do
  # Skip built-in plugins
  [[ $plugin != *"/"* ]] && continue

  name="$(cut -d "/" -f2 <<<$plugin)"
  zsh_custom_plugin_path="$ZSH_CUSTOM/plugins/$name"
  if [ ! -d "$zsh_custom_plugin_path" ]; then
    git clone https://github.com/"$plugin".git "$zsh_custom_plugin_path"
  fi

  plugins+=($name)
done

source $ZSH/oh-my-zsh.sh >/dev/null 2>&1
source $ZSH_CUSTOM/plugins/zsh-autocomplete

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"

if [ -s "$NVM_DIR/nvm.sh" ]; then
  \. "$NVM_DIR/nvm.sh" # This loads nvm
else
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
  \. "$NVM_DIR/nvm.sh" # This loads nvm
  nvm install 16
fi

# User configuration
# For a full list of active aliases, run `alias`.

# JAKE CONFIG/ALIASES
export LANG=en_US.UTF-8
export PURE_POWER_MODE=modern
export POWERLEVEL9K_MODE='nerdfont-complete'
export NVIM_DIR=$HOME/.config/nvim
export GPG_TTY=$(tty)
export TMUX_DIR=$HOME/.config/tmux
export TMUX_TPM_DIR_PATH=$TMUX_DIR/plugins/tpm
export EDITOR=$(which nvim)

alias npm-what=npm pack && tar -xvzf *.tgz && rm -rf package *.tgz
alias ssh-pi="ssh pi@raspberrypi.local"
alias vim="nvim"
alias grep="rg"
alias printdoc=lpr
alias pacman='sudo pacman'
alias shutdown='sudo shutdown'
alias reboot='sudo reboot'

if [ ! -d "$TMUX_TPM_DIR_PATH" ]; then
  git clone https://github.com/tmux-plugins/tpm $TMUX_TPM_DIR_PATH
fi

set -o vi

git config --global core.editor $(which nvim)
git config --global pull.rebase true
git config --global init.defaultBranch main
git config --global user.email 'jakehamtexas@gmail.com'
git config --global user.name 'Jake Hamilton'
git config --global fetch.prune true

git config --global alias.a add
git config --global alias.aa 'add .'
git config --global alias.ap 'add -p'
git config --global alias.ca commit
git config --global alias.ca 'commit -a'
git config --global alias.cp 'commit -p'
git config --global alias.cam 'commit -a -m'
git config --global alias.cpm 'commit -p -m'
git config --global alias.caa 'commit -a --amend'
git config --global alias.caam 'commit -a --amend -m'
git config --global alias.can 'commit --amend --no-edit'
git config --global alias.cpan 'commit -p --amend --no-edit'
git config --global alias.caan 'commit -a --amend --no-edit'

git config --global alias.fp 'push -u origin --force-with-lease'

git config --global alias.rd 'rebase origin/develop'
git config --global alias.rid 'rebase -i origin/develop'
git config --global alias.rc 'rebase --continue'

git config --global alias.aliases "! git config --get-regexp '^alias\.' | cat"

source $HOME/dotfiles.alias

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
  if [ "$PWD" = "$HOME" ] && [ -n "$DISPLAY" ] ; then
    export GIT_DIR=$DOTFILES_GIT_DIR
    export GIT_WORK_TREE=$HOME
  else
    unset GIT_DIR
    unset GIT_WORK_TREE
  fi
}

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
  _can_check && _check_for_new_dotfiles_revision
  handle_home_dir
  $TMUX_DIR/install.sh quiet
}

chpwd

# SAFEBASE CONFIG/ALIASES
export VIM_LOCAL_CONFIG_DIR_PATH="$HOME/projects/monorepo/work/develop/.vim"
export CYPRESS_SECRETS_PATH="$HOME/cypress.env.json"

alias arm64bi='arch -arm64 brew install'
alias setup="$HOME/scripts/prepare_dev.sh &"


[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ] && command -v startx; then
  exec startx
fi
