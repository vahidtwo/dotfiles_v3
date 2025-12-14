
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"


export EDITOR=vim
export VISUAL=vim

export PATH=$HOME/MyScript:$PATH:~/.local/bin:$HOME/.config/composer/vendor/bin:$HOME/minio-binaries/
export PATH=$PATH:~/go/bin


#################
## completions ##
#################

autoload -Uz compinit && compinit
zinit cdreplay -q


autoload -Uz compinit
compinit -i

## fzf-tab
zinit light Aloxaf/fzf-tab



## zsh-syntax-highlighting
zinit light zsh-users/zsh-syntax-highlighting
## zsh-completions
zinit light zsh-users/zsh-completions
## zsh-autosuggestions
zinit light zsh-users/zsh-autosuggestions
zinit snippet OMZP::command-not-found
zinit snippet OMZP::sudo

zinit light Aloxaf/fzf-tab
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit snippet OMZ::plugins/git/git.plugin.zsh  # Ensure Git plugin is loaded
zinit snippet OMZP::command-not-found
zinit snippet OMZP::sudo
zinit snippet OMZP::kubectl
zinit snippet OMZP::archlinux
zinit snippet OMZP::ssh-agent

zinit snippet OMZL::clipboard.zsh
zinit snippet OMZL::termsupport.zsh
zinit snippet OMZL::git.zsh
zinit snippet OMZL::functions.zsh
zinit snippet OMZL::compfix.zsh
zinit snippet OMZL::clipboard.zsh
zinit snippet OMZL::directories.zsh
zinit snippet OMZL::grep.zsh


zinit cdreplay -q

###########
## inits ##
###########
if command -v atuin &> /dev/null; then
  export ATUIN_NOBIND="true"
  eval "$(atuin init zsh)"
  bindkey '^r' atuin-search
fi



zstyle :omz:plugins:ssh-agent agent-forwarding yes
## ask ssh key passphrase only after first use
zstyle :omz:plugins:ssh-agent lazy yes
## don't print anything, so it plays nice with powerline 10k instant prompt
zstyle :omz:plugins:ssh-agent quiet yes
## make autocompletions case insensitive
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
## make them colorful
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

## make them use fzf
zstyle ':completion:*' menu no

# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false

## show directory when cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'


HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase

setopt appendhistory
setopt share_history
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups
setopt numericglobsort



#############
## options ##
#############
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

alias vaultrun="docker run --cap-add=IPC_LOCK --name=dev-vault -p 8200:8200 -d -e 'VAULT_DEV_ROOT_TOKEN_ID=vahid' hashicorp/vault server -dev"
alias kpod="watch -n 1  \"kubectl get pods -o wide\""
alias gmr='git branch --merged | grep -Ev "(^\*|master|main|dev|staging)" | xargs git branch -d'
alias f='fuck'
alias c='code .'
alias cdp='cd ~/p'
alias cov='export PHASE=test;rm .coverage && rm -rf coverage_html_report && coverage run  manage.py test --noinput && coverage report && coverage html ; xdg-open coverage_html_report/index.html;unset PHASE'
alias boost='pamixer --allow-boost --set-volume $1'
alias cl="clear"
alias v="vim"
alias ae="deactivate;source ./.venv/bin/activate"
alias de="deactivate"
alias dgma="python manage.py makemigrations"
alias dgmi="python manage.py migrate"
alias dt="export PHASE=test;python manage.py test --no-input -v 3 --keepdb --failfast $1 ;unset PHASE"
alias pacmanmirror='sudo reflector --verbose --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist'
alias ll="ls -ltrha"
alias vi="vim"

upcode() {
    echo current version: $(code -v | head -n 1);
    echo unzip source;
    mkdir -p /tmp/vscode-files/;
    tar -C /tmp/vscode-files -xf $1;
    echo remove current version
    sudo rm -rf /opt/vscode;
    echo replace new version
    sudo cp -r /tmp/vscode-files/* /opt/vscode;
    echo create link
    sudo ln -sf /opt/vscode/bin/code /usr/bin/code
    echo updated successfully!
    echo current version: $(code -v | head -n 1);
}
infdt(){
test_module=$1
echo $test_module ;
while true; do
	DJANGO_LOG_LEVEL=DEBUG

	if [ -z "$test_module" ]; then
	    echo "Running all Django tests..."
	    python manage.py test
	else
	    echo "Running Django tests for module: $test_module"
	    python manage.py test $test_module --failfast  --pdb -b --traceback --no-input --debug-mode
	fi
	if [ $? -ne 0 ]; then
	    echo "Tests failed."
	    break
	else
	    echo "All tests passed."
	fi
done
}

#git
# Added by oh-my-vim

export LESS="--chop-long-lines --HILITE-UNREAD --ignore-case \
	--incsearch --jump-target=4 --LONG-PROMPT --no-init \
	--quit-if-one-screen --RAW-CONTROL-CHARS --use-color --window=-4"
___MY_VMOPTIONS_SHELL_FILE="${HOME}/.jetbrains.vmoptions.sh"; if [ -f "${___MY_VMOPTIONS_SHELL_FILE}" ]; then . "${___MY_VMOPTIONS_SHELL_FILE}"; fi
source <(kubectl completion zsh)
eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/base.json)"

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /home/vahidtwo/minio-binaries/mc mc
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PATH:$PYENV_ROOT/bin"
eval "$(pyenv init - zsh)"



bindkey "^[[H" beginning-of-line  # Home key
bindkey "^[[F" end-of-line        # End key
bindkey "^[[3~" delete-char       # Delete key

source /usr/share/doc/pkgfile/command-not-found.zsh

export PATH=$PATH:/home/vahidtwo/.local/bin
eval "$(thefuck --alias)"
eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"


fastfetch
jcal

#############################################30














source ~/.zsh_welcome



