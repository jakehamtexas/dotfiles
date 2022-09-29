# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Add rustup completions if they exist
[ -d $HOME/.zfunc ] && fpath+=$HOME/.zfunc

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM=$ZSH/custom

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="agnoster"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

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
# ENABLE_CORRECTION="true"

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

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
source $ZSH_CUSTOM/plugins/zsh-autocomplete

export NVM_DIR="$HOME/.nvm"
source ~/.zsh-nvm/zsh-nvm.plugin.zsh                               # This loads nvm
alias npm-what=npm pack && tar -xvzf *.tgz && rm -rf package *.tgz
alias ssh-pi="ssh pi@raspberrypi.local"

PURE_POWER_MODE=modern
POWERLEVEL9K_MODE='nerdfont-complete'

alias ff="firefox -P Jake &"
alias ff-work="firefox -P Respondent &"
alias disco="discord &"
alias screencap="flameshot &"
alias vim="nvim"
alias slack="slack &"
alias grep="rg"
alias mount-respondent="sshfs -o Ciphers=arcfour -o Compression=no -o IdentityFile=$HOME/.ssh/work_rsa jake@work.local://Users/jake ~/respondent"
alias unmount-respondent="fusermount3 -u ~/respondent"
alias printdoc=lpr
export NVIM_DIR=$HOME/.config/nvim
export NVIM_PLUGIN_DIR=$NVIM_DIR/plugins
alias arm64bi='arch -arm64 brew install'

export VIM_LOCAL_CONFIG_DIR_PATH="$HOME/projects/monorepo/work/develop/.vim"
export CYPRESS_SECRETS_PATH="$HOME/cypress.env.json"

alias setup="$HOME/scripts/prepare_dev.sh &"
alias clint="$HOME/scripts/eslint.sh"

export GPG_TTY=$(tty)
export TMUX_DIR=$HOME/.config/tmux

export EDITOR=$(which nvim)

if [ ! -d $HOME/.config/tmux/plugins/tpm ]; then
  git clone https://github.com/tmux-plugins/tpm $HOME/.config/tmux/plugins/tpm
fi

set -o vi

git config --global core.editor $(which nvim)
git config --global pull.rebase true
git config --global init.defaultBranch main
git config --global user.email 'jakehamtexas@gmail.com'
git config --global user.name 'Jake Hamilton'
git config --global fetch.prune true

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

chpwd () {
  handle_home_git_dir
}

alias branch-clean="git branch -vv | grep ': gone]' | grep -v '\*' | awk '{ print \$1; }'"
handle_home_git_dir 
