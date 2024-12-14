#!/usr/bin/env bash

case "${UNAME_S:?}" in
Darwin)
	alias arm64bi='arch -arm64 brew install'
	;;
esac

start_nvim() {
	if command -v nvm >/dev/null; then
		# This should fail if nvm use default didn't work.
		(nvm use || nvm use default) && nvim
	else
		nvim
	fi
}

alias npm-what=npm pack && tar -xvzf ./*.tgz && rm -rf package ./*.tgz
alias vim="start_nvim"
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

git config --global alias.fp '!f(){ git fetch; git push -u --force-with-lease $@; }; f'
git config --global alias.fpp '!f(){ git fp --no-verify; }; f'

# shellcheck disable=SC2016
git config --global alias.r '!f(){ git fetch; git rebase $($HOME/scripts/git_upstream_branch.sh $1); }; f'
# shellcheck disable=SC2016
git config --global alias.ri '!f(){ git fetch; git rebase -i $($HOME/scripts/git_upstream_branch.sh $1); }; f'
git config --global alias.rim '!f(){ git ri main; }; f'
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

	if command -v direnv &>/dev/null && test -s .envrc; then
		direnv allow
	fi

	nvm_use
}

gh_path="$(which gh)"

gh() {
	if ! command -v "$gh_path" >/dev/null 2>&1; then
		echo "gh not installed"
		return 1
	fi

	if [[ "$1" == "pr" && "$2" == "create" && "$3" ]]; then
		local do_prepush=true
		for f in "$@"; do
			if [[ "$f" == "--no-verify" || "$f" == "--help" ]]; then
				do_prepush=false
			fi
		done

		if [ "$do_prepush" = true ]; then
			git push -u origin HEAD
		fi
	fi

	"$gh_path" "$@"
}

function lazy() {
  case "${1:?Must specify first argument('sync' | 'restore' | 'clean' | 'update')}" in
	'sync' | 'restore' | 'clean' | 'update')
		# Valid args
		;;
	*)
		echo "Invalid argument: $1"
		;;
	esac

	nvim --headless "+Lazy! $1" +qa
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

# BEGIN NVM
# NOTE: Must come before lugin loading
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

# PLUGINS
. "$ZDOTDIR/zgenom/source.sh"

export HISTORY_FILTER_EXCLUDE=("_KEY" "Bearer")
# END PLUGINS

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

. "${ZDOTDIR:?}"/gcloud.sh

# Prompt
. "${ZDOTDIR}"/oh-my-posh/source.sh
