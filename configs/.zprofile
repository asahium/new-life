# ===========================================
# .zprofile - runs before .zshrc
# ===========================================

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Pyenv (must be in .zprofile for instant prompt)
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"

