# ===========================================
# Oh My Zsh
# ===========================================

export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    fzf
    docker
    zoxide
    command-not-found
    colored-man-pages
)

source $ZSH/oh-my-zsh.sh

# ===========================================
# Powerlevel10k instant prompt
# ===========================================
# Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Load Powerlevel10k config
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# ===========================================
# Environment
# ===========================================

export EDITOR="nvim"
export VISUAL="nvim"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Homebrew (Apple Silicon)
if [[ $(uname -m) == "arm64" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ===========================================
# pyenv
# ===========================================

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)" 2>/dev/null
eval "$(pyenv virtualenv-init -)" 2>/dev/null

# ===========================================
# nvm
# ===========================================

export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# ===========================================
# PATH
# ===========================================

export PATH="$HOME/.local/bin:$PATH"

# ===========================================
# FZF
# ===========================================

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export FZF_DEFAULT_OPTS="
    --height 40%
    --layout=reverse
    --border
    --info=inline
    --color=fg:#D8DEE9,bg:#2E3440,hl:#A3BE8C
    --color=fg+:#ECEFF4,bg+:#434C5E,hl+:#A3BE8C
    --color=info:#81A1C1,prompt:#88C0D0,pointer:#BF616A
    --color=marker:#A3BE8C,spinner:#B48EAD,header:#88C0D0
"

# Use fd for fzf if available
if command -v fd &> /dev/null; then
    export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"
fi

# ===========================================
# zoxide (better cd)
# ===========================================

eval "$(zoxide init zsh)" 2>/dev/null

# ===========================================
# Aliases — Git
# ===========================================

alias gs="git status"
alias gp="git push"
alias gpl="git pull"
alias gcm="git commit -m"
alias gaa="git add --all"
alias lg="lazygit"
alias glog="git log --oneline --graph --decorate -20"
alias gd="git diff"
alias gco="git checkout"
alias gb="git branch"
alias gst="git stash"

# ===========================================
# Aliases — Files & Navigation
# ===========================================

alias ll="eza -la --icons --git --group-directories-first"
alias lt="eza --tree --level=2 --icons"
alias la="eza -la --icons"
alias l="eza -l --icons"
alias cat="bat --paging=never"
alias tree="eza --tree --icons"

# ===========================================
# Aliases — Python
# ===========================================

alias venv="python -m venv .venv"
alias activate="source .venv/bin/activate"
alias py="python"
alias ipy="ipython"

# ===========================================
# Aliases — Docker
# ===========================================

alias d="docker"
alias dc="docker compose"
alias dps="docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
alias dprune="docker system prune -af"

# ===========================================
# Aliases — System
# ===========================================

alias reload="source ~/.zshrc"
alias zshrc="$EDITOR ~/.zshrc"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias rm="trash"
alias df="df -h"
alias du="du -h"
alias top="btop"
alias grep="rg"
alias find="fd"

# ===========================================
# Functions
# ===========================================

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract any archive
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"   ;;
            *.tar.gz)    tar xzf "$1"   ;;
            *.bz2)       bunzip2 "$1"   ;;
            *.rar)       unrar x "$1"   ;;
            *.gz)        gunzip "$1"    ;;
            *.tar)       tar xf "$1"    ;;
            *.tbz2)      tar xjf "$1"   ;;
            *.tgz)       tar xzf "$1"   ;;
            *.zip)       unzip "$1"     ;;
            *.Z)         uncompress "$1";;
            *.7z)        7z x "$1"      ;;
            *)           echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Quick git commit with message
gc() {
    git add --all && git commit -m "$*"
}

# Show port usage
port() {
    lsof -i :"$1"
}
