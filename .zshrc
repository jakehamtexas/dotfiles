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

# TMUX
if ! infocmp tmux-256color > /dev/null 2>&1; then
  terminfo_dir=/tmp/tmux-terminfo

  mkdir -p $terminfo_dir

  terminfo_zipped=$terminfo_dir/info.src.gz
  curl 'https://invisible-island.net/datafiles/current/terminfo.src.gz' -o $terminfo_zipped > /dev/null 2>&1

  terminfo_unzipped=$terminfo_dir/info.src
  gunzip $terminfo_zipped > /dev/null 2>&1
  tic -xe tmux-256color $terminfo_unzipped > /dev/null 2>&1
fi

if [ ! -d "$TMUX_TPM_DIR_PATH" ]; then
  git clone https://github.com/tmux-plugins/tpm $TMUX_TPM_DIR_PATH
fi

set -o vi

# Refer to .zshenv for definition of chpwd
chpwd

if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ] && command -v startx; then
  exec startx
fi
