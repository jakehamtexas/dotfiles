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

export NVM_DIR="$HOME/.nvm"
test -f "$HOME/.zsh-nvm/zsh-nvm.plugin.zsh" && source "$HOME/.zsh-nvm/zsh-nvm.plugin.zsh" # This loads nvm

# User configuration
# For a full list of active aliases, run `alias`.

# JAKE CONFIG/ALIASES
export LANG=en_US.UTF-8
export PURE_POWER_MODE=modern
export POWERLEVEL9K_MODE='nerdfont-complete'
export NVIM_DIR=$HOME/.config/nvim
export NVIM_PLUGIN_DIR=$NVIM_DIR/plugins
export GPG_TTY=$(tty)
export TMUX_DIR=$HOME/.config/tmux
export EDITOR=$(which nvim)

alias npm-what=npm pack && tar -xvzf *.tgz && rm -rf package *.tgz
alias ssh-pi="ssh pi@raspberrypi.local"
alias vim="nvim"
alias grep="rg"
alias printdoc=lpr

if [ ! -d "$TMUX_DIR/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm $HOME/.config/tmux/plugins/tpm
fi

set -o vi

git config --global core.editor $(which nvim)
git config --global pull.rebase true
git config --global init.defaultBranch main
git config --global user.email 'jakehamtexas@gmail.com'
git config --global user.name 'Jake Hamilton'
git config --global fetch.prune true

git config --global alias.ca 'commit -a'
git config --global alias.cam 'commit -a -m'
git config --global alias.caa 'commit -a --amend'
git config --global alias.caam 'commit -a --amend -m'
git config --global alias.caan 'commit -a --amend --no-edit'

git config --global alias.fp 'push -u origin --force-with-lease'

git config --global alias.rd 'rebase origin/develop'
git config --global alias.rid 'rebase -i origin/develop'
git config --global alias.rc 'rebase --continue'

git config --global alias.aliases "! git config --get-regexp '^alias\.' | cat"

source $HOME/dotfiles.alias

handle_home_git_dir () {
  if [ "$PWD" = "$HOME" ]; then
    export GIT_DIR=$DOTFILES_GIT_DIR
    export GIT_WORK_TREE=$HOME
  else
    unset GIT_DIR
    unset GIT_WORK_TREE
  fi
}

dotfiles_diff() {
  local branch_status=$(dotfiles status -b --porcelain)
  local without_leading_hashes=(${(s/##/)branch_status})
  local branches_only=$(echo $without_leading_hashes | head -1)
  local branches=(${(s/.../)branches_only})

  local local_branch=$(echo $branches | cut -d' ' -f2)
  local remote_branch=$(echo $branches | cut -d' ' -f3)

  dotfiles -c color.status=always diff $local_branch $remote_branch
}

check_for_new_dotfiles_revision () {
  local dotfiles_diff=$(dotfiles_diff)
  [ -z $dotfiles_diff ] && exit

  echo ''
  echo 'New changes in upstream dotfiles!'
  echo 'Use function "dotfiles_diff" to see them'
  echo ''
}

chpwd () {
  handle_home_git_dir
  check_for_new_dotfiles_revision
}

handle_home_git_dir 
check_for_new_dotfiles_revision 

# SAFEBASE CONFIG/ALIASES
export VIM_LOCAL_CONFIG_DIR_PATH="$HOME/projects/monorepo/work/develop/.vim"
export CYPRESS_SECRETS_PATH="$HOME/cypress.env.json"

alias arm64bi='arch -arm64 brew install'
alias setup="$HOME/scripts/prepare_dev.sh &"

