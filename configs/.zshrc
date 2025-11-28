# ===========================================
# Powerlevel10k Instant Prompt
# ===========================================
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ===========================================
# Oh My Zsh Configuration
# ===========================================
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins (removed docker/kubectl/pyenv to avoid errors if not installed)
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    fzf
    pip
    python
    macos
    brew
    history
    colored-man-pages
)

source $ZSH/oh-my-zsh.sh

# ===========================================
# PATH Configuration
# ===========================================
# pipx
export PATH="$PATH:$HOME/.local/bin"

# ===========================================
# Pyenv Configuration
# ===========================================
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv &>/dev/null; then
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

# ===========================================
# NVM Configuration
# ===========================================
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# ===========================================
# Zoxide (better cd)
# ===========================================
eval "$(zoxide init zsh)"

# ===========================================
# FZF Configuration
# ===========================================
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

# ===========================================
# Aliases - Navigation
# ===========================================
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"

# ===========================================
# Aliases - Modern CLI Tools
# ===========================================
alias ls="eza --icons"
alias ll="eza -la --icons --git"
alias la="eza -a --icons"
alias lt="eza --tree --level=2 --icons"
alias cat="bat --paging=never"

# ===========================================
# Aliases - Git
# ===========================================
alias g="git"
alias gs="git status"
alias ga="git add"
alias gaa="git add -A"
alias gc="git commit"
alias gcm="git commit -m"
alias gp="git push"
alias gpl="git pull"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gb="git branch"
alias gd="git diff"
alias gl="git log --oneline -15"
alias glog="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias lg="lazygit"

# ===========================================
# Aliases - Python
# ===========================================
alias python="python3"
alias pip="pip3"
alias venv="python -m venv .venv"
alias activate="source .venv/bin/activate"
alias pipreq="pip freeze > requirements.txt"

# ===========================================
# Aliases - Docker
# ===========================================
alias d="docker"
alias dc="docker compose"
alias dps="docker ps"
alias dpsa="docker ps -a"
alias di="docker images"
alias dprune="docker system prune -af"

# ===========================================
# Aliases - Misc
# ===========================================
alias c="clear"
alias h="history"
alias reload="source ~/.zshrc"
alias zshconfig="$EDITOR ~/.zshrc"
alias hosts="sudo $EDITOR /etc/hosts"
alias ip="curl -s ipinfo.io | jq"
alias localip="ipconfig getifaddr en0"
alias flushdns="sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"

# ===========================================
# Aliases - Safety
# ===========================================
alias rm="trash"             # Move to trash instead of delete
alias cp="cp -i"             # Confirm before overwriting
alias mv="mv -i"             # Confirm before overwriting

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
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Quick backup file
backup() {
    cp "$1" "$1.backup.$(date +%Y%m%d%H%M%S)"
}

# Show top 10 most used commands
topcmd() {
    history | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl | head -n10
}

# ===========================================
# Environment Variables
# ===========================================
export EDITOR="nvim"
export VISUAL="$EDITOR"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# History configuration
export HISTSIZE=50000
export SAVEHIST=50000
export HISTFILE=~/.zsh_history
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt SHARE_HISTORY

# ===========================================
# Powerlevel10k Configuration
# ===========================================
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

