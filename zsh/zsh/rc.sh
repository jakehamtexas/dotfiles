#!/usr/bin/env bash

case "${UNAME_S:?}" in
Darwin)
	alias arm64bi='arch -arm64 brew install'
	;;
esac

alias npm-what=npm pack && tar -xvzf ./*.tgz && rm -rf package ./*.tgz
alias vim="nvim"
alias grep="rg"
alias printdoc=lpr
alias pacman='sudo pacman'
alias shutdown='sudo shutdown'
alias reboot='sudo reboot'

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

# shellcheck disable=SC2016
git config --global alias.r '!f(){ git rebase $($HOME/scripts/git_upstream_branch.sh $1); }; f'
# shellcheck disable=SC2016
git config --global alias.ri '!f(){ git rebase -i $($HOME/scripts/git_upstream_branch.sh $1); }; f'
git config --global alias.rc 'rebase --continue'

# shellcheck source=$HOME/scripts/sb-worktree/env.sh
# shellcheck disable=SC1091
. ~/scripts/sb-worktree/env.sh
# shellcheck disable=SC2016
git config --global alias.wa '!sh $HOME/scripts/sb-worktree/add.sh'
git config --global alias.wr 'worktree remove'
# shellcheck disable=SC2016
git config --global alias.wrf '!f(){ git worktree remove --force $(realpath $1); git worktree prune; }; f'
git config --global alias.wrp 'worktree prune'

git config --global alias.bsc 'branch --show-current'

git config --global alias.aliases "! git config --get-regexp '^alias\.' | cat"

# Add dir for rustup completions, if it doesn't exist
mkdir -p ~/.zfunc
fpath+=~/.zfunc

nvm_use() {
	if [ -f .nvmrc ]; then
		nvm use
	fi
}

chpwd() {
	handle_new_worktree

	nvm_use
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

	"$gh_path" "$@"
}

alias sbpd=./prepare_dev.sh

alias yr='yarn run'
alias yrd='yr dev'
alias yrtc='yr g:type-check'
alias yrg='yarn && yr generate' # The most often needed part of prepare dev when rebasing
alias yrpp='yr g:pre-push'

alias pr='$HOME/scripts/pr/pr.sh'
alias review='$HOME/scripts/clone-review.sh'

. "$HOME"/scripts/git.sh

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

if [ ! -d "$ZSH" ]; then
	export KEEP_ZSHRC=yes
	sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
fi

export ZSH_CUSTOM=$ZSH/custom

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
export ZSH_THEME="agnoster"

# Uncomment the following line to automatically update without prompting.
export DISABLE_UPDATE_PROMPT="true"

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
export COMPLETION_WAITING_DOTS="true"

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

# BEGIN NVM
# NOTE: Must come before plugin loading
NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
export NVM_DIR
export NVM_COMPLETION=true
export NVM_AUTO_USE=true
export NVM_LAZY_LOAD=true
export NVM_LAZY_LOAD_EXTRA_COMMANDS=('vim' 'nvim')
export NVM_LAZY_AUTO_DIR="$HOME/projects"

activate_nvm() {
	# checking dir in path, and if node is a shell function (not loaded)
	if [[ -f "$PWD"/.nvmrc && "$(type node)" = *'a shell function'* ]]; then
		print 'Activating nvm...'
		nvm_use
		# trigger loading
		node --version
		# cd into same dir to activate auto_use
		cd "$PWD" || exit
	fi
}

# use this function if LAZY_LOAD is true
if [ "$NVM_LAZY_LOAD" = true ]; then
	precmd_functions+=(activate_nvm)
fi
# END NVM

plugin_path="$ZSH_CUSTOM/plugins"

clear_plugins() {
	rm -rf "$plugin_path"
}

# shellcheck source=$HOME/.oh-my-zsh/custom/plugins/zsh-autocomplete
zsh_autocomplete_path="$plugin_path/zsh-autocomplete"
revert_autocomplete() {
	last_working_commit=d8bfbef46efc54c1189010a3b70d501b44487504
	(cd "$zsh_autocomplete_path" && git checkout "$last_working_commit" >/dev/null 2>&1)
	exec zsh
}

plugins=()

_plugins=(
	git
	docker
	docker-compose
	'MichaelAquilina/zsh-history-filter'
	'marlonrichert/zsh-autocomplete'
	'zsh-users/zsh-autosuggestions'
	'zsh-users/zsh-syntax-highlighting'
	'b4b4r07/enhancd'
	'unixorn/fzf-zsh-plugin'
	'lukechilds/zsh-nvm'
)

for plugin in "${_plugins[@]}"; do
	# Skip built-in plugins
	[[ $plugin != *"/"* ]] && continue

	name="$(cut -d "/" -f2 <<<"$plugin")"
	zsh_custom_plugin_path="$plugin_path/$name"
	if [ ! -d "$zsh_custom_plugin_path" ]; then
		git clone https://github.com/"$plugin".git "$zsh_custom_plugin_path"
	fi

	plugins+=("$name")
done

# shellcheck source=$HOME/.oh-my-zsh/.oh-my-zsh.sh
# Providing a source to shellcheck doesn't seem to work here.
# Shellcheck doesn't believe that the file exists.
# shellcheck disable=SC1091
. "$ZSH"/oh-my-zsh.sh >/dev/null 2>&1
if [ -f "$zsh_autocomplete_path" ]; then
	# Same here
	# shellcheck source=$HOME/.oh-my-zsh/custom/plugins/zsh-autocomplete
	# shellcheck disable=SC1091
	. "$zsh_autocomplete_path"
fi

export HISTORY_FILTER_EXCLUDE=("_KEY" "Bearer")

# TMUX
# Used by tmux to enable 256 color support
export ORIGINAL_TERM=$TERM
if ! infocmp tmux-256color >/dev/null 2>&1; then
	terminfo_dir=/tmp/tmux-terminfo

	mkdir -p "$terminfo_dir"

	terminfo_zipped=$terminfo_dir/info.src.gz
	curl 'https://invisible-island.net/datafiles/current/terminfo.src.gz' -o "$terminfo_zipped" >/dev/null 2>&1

	terminfo_unzipped=$terminfo_dir/info.src
	gunzip "$terminfo_zipped" >/dev/null 2>&1
	tic -xe tmux-256color "$terminfo_unzipped" >/dev/null 2>&1
fi
# END TMUX

set -o vi

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null 2>&1 || export PATH="$PYENV_ROOT/bin:$PATH"

if command -v pyenv >/dev/null 2>&1; then
	eval "$(pyenv init -)"
fi

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/bin/terraform terraform

if command -v terraform >/dev/null; then
	complete -o nospace -C "$(which terraform)" terraform
fi
