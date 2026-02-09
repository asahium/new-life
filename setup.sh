#!/bin/bash

# ===========================================
# New Machine Setup Script
# ===========================================
# Run: chmod +x setup.sh && ./setup.sh

set -e  # Exit on error

# ===========================================
# Configuration — edit these to customize
# ===========================================

GIT_EMAIL=""               # Will prompt if empty
GIT_NAME=""                # Will prompt if empty
PYTHON_VERSIONS=("3.11.11" "3.12.8")
PYTHON_GLOBAL="3.12.8"
PIPX_PACKAGES=(
    "poetry"
    "black"
    "ruff"
    "mypy"
    "isort"
    "wandb"
    "jupyter"
    "jupyterlab"
    "pytest"
    "pre-commit"
    "httpie"
    "tldr"
)

# ===========================================
# Colors & helpers
# ===========================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/setup.log"

# Global flags
UPDATE_PACKAGES=false

# ===========================================
# Helper Functions
# ===========================================

print_header() {
    echo ""
    echo -e "${BLUE}=============================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}=============================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}→ $1${NC}"
}

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# Wrap command with logging — stdout/stderr go to log, errors shown to user
run_logged() {
    log "Running: $*"
    if ! "$@" >> "$LOG_FILE" 2>&1; then
        log "FAILED: $*"
        return 1
    fi
}

backup_file() {
    local file="$1"
    if [ -f "$file" ]; then
        local backup="${file}.backup.$(date +%Y%m%d%H%M%S)"
        cp "$file" "$backup"
        print_info "Backed up $file → $backup"
        log "Backed up $file → $backup"
    fi
}

# Check if app is installed
app_installed() {
    local app_name="$1"
    [ -d "/Applications/${app_name}.app" ] || [ -d "$HOME/Applications/${app_name}.app" ]
}

# Ask to install with default No
ask_install() {
    local name="$1"
    read -p "  Install ${name}? [y/N] " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# ===========================================
# 0. Gather user info
# ===========================================

gather_user_info() {
    print_header "User Configuration"

    if [ -z "$GIT_NAME" ]; then
        read -p "  Your full name (for git): " GIT_NAME
    fi
    if [ -z "$GIT_EMAIL" ]; then
        read -p "  Your email (for git & SSH key): " GIT_EMAIL
    fi

    print_success "Name: $GIT_NAME"
    print_success "Email: $GIT_EMAIL"
    log "User: $GIT_NAME <$GIT_EMAIL>"
}

# ===========================================
# 1. Install Homebrew
# ===========================================

install_homebrew() {
    print_header "Installing Homebrew"

    if command -v brew &> /dev/null; then
        print_success "Homebrew is already installed"
        print_info "Updating Homebrew..."
        run_logged brew update
    else
        print_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH for Apple Silicon
        if [[ $(uname -m) == "arm64" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi

        print_success "Homebrew installed"
        log "Homebrew installed"
    fi
}

# ===========================================
# 2. Install Brewfile packages
# ===========================================

install_brew_packages() {
    print_header "Installing Brew Packages"

    if [ ! -f "$SCRIPT_DIR/Brewfile" ]; then
        print_error "Brewfile not found at $SCRIPT_DIR/Brewfile"
        exit 1
    fi

    # Install taps
    print_info "Adding taps..."
    grep '^tap ' "$SCRIPT_DIR/Brewfile" | while read -r line; do
        tap_name=$(echo "$line" | sed 's/tap "\(.*\)"/\1/')
        run_logged brew tap "$tap_name" || true
    done

    # Install/update formulae (CLI tools)
    print_info "Installing CLI tools..."
    grep '^brew ' "$SCRIPT_DIR/Brewfile" | while read -r line; do
        formula=$(echo "$line" | sed 's/brew "\([^"]*\)".*/\1/')
        if brew list "$formula" &>/dev/null; then
            if [ "$UPDATE_PACKAGES" = true ]; then
                if brew outdated "$formula" &>/dev/null; then
                    print_info "Updating $formula..."
                    run_logged brew upgrade "$formula" || print_warning "Failed to update $formula"
                else
                    print_success "$formula (up to date)"
                fi
            else
                print_success "$formula (already installed)"
            fi
        else
            print_info "Installing $formula..."
            run_logged brew install "$formula" || print_warning "Failed to install $formula"
        fi
    done

    # Install casks (GUI apps) - check if already installed
    print_info "Installing GUI applications..."

    grep '^cask ' "$SCRIPT_DIR/Brewfile" | while read -r line; do
        cask=$(echo "$line" | sed 's/cask "\([^"]*\)".*/\1/')

        # Map cask to app name for detection
        case "$cask" in
            "iterm2")            app_name="iTerm" ;;
            "ghostty")           app_name="Ghostty" ;;
            "kitty")             app_name="kitty" ;;
            "cursor")            app_name="Cursor" ;;
            "zed")               app_name="Zed" ;;
            "visual-studio-code") app_name="Visual Studio Code" ;;
            "docker")            app_name="Docker" ;;
            "jetbrains-toolbox") app_name="JetBrains Toolbox" ;;
            "obsidian")          app_name="Obsidian" ;;
            "telegram")          app_name="Telegram" ;;
            "zoom")              app_name="zoom.us" ;;
            "brave-browser")     app_name="Brave Browser" ;;
            "vlc")               app_name="VLC" ;;
            "obs")               app_name="OBS" ;;
            "the-unarchiver")    app_name="The Unarchiver" ;;
            *)                   app_name="$cask" ;;
        esac

        # Skip fonts — just install them silently
        if [[ "$cask" == font-* ]]; then
            if brew list --cask "$cask" &>/dev/null; then
                print_success "$cask (already installed)"
            else
                print_info "Installing font: $cask..."
                run_logged brew install --cask "$cask" --no-quarantine || true
            fi
            continue
        fi

        # Check if app exists
        if app_installed "$app_name"; then
            if [ "$UPDATE_PACKAGES" = true ]; then
                if brew outdated --cask "$cask" &>/dev/null 2>&1; then
                    print_info "Updating $app_name..."
                    run_logged brew upgrade --cask "$cask" || print_warning "Failed to update $cask"
                else
                    print_success "$app_name (up to date)"
                fi
            else
                print_success "$app_name (already installed)"
            fi
        else
            if ask_install "$app_name"; then
                print_info "Installing $cask..."
                run_logged brew install --cask "$cask" --no-quarantine || print_warning "Failed to install $cask"
            else
                print_warning "Skipped $app_name"
            fi
        fi
    done

    print_success "Brew packages installed"
    log "Brew packages step completed"
}

# ===========================================
# 3. Install Oh My Zsh
# ===========================================

install_oh_my_zsh() {
    print_header "Installing Oh My Zsh"

    if [ -d "$HOME/.oh-my-zsh" ]; then
        print_success "Oh My Zsh is already installed"
    else
        print_info "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        print_success "Oh My Zsh installed"
    fi

    # Install Powerlevel10k theme
    print_info "Installing Powerlevel10k theme..."
    local p10k_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    if [ -d "$p10k_dir" ]; then
        print_success "Powerlevel10k is already installed"
    else
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
        print_success "Powerlevel10k installed"
    fi

    # Install zsh-autosuggestions plugin
    print_info "Installing zsh-autosuggestions..."
    local autosuggestions_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
    if [ -d "$autosuggestions_dir" ]; then
        print_success "zsh-autosuggestions is already installed"
    else
        git clone https://github.com/zsh-users/zsh-autosuggestions "$autosuggestions_dir"
        print_success "zsh-autosuggestions installed"
    fi

    # Install zsh-syntax-highlighting plugin
    print_info "Installing zsh-syntax-highlighting..."
    local syntax_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
    if [ -d "$syntax_dir" ]; then
        print_success "zsh-syntax-highlighting is already installed"
    else
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$syntax_dir"
        print_success "zsh-syntax-highlighting installed"
    fi

    # Copy Powerlevel10k config if provided
    if [ -f "$SCRIPT_DIR/configs/.p10k.zsh" ]; then
        backup_file "$HOME/.p10k.zsh"
        cp "$SCRIPT_DIR/configs/.p10k.zsh" "$HOME/.p10k.zsh"
        print_success "Copied Powerlevel10k config (.p10k.zsh)"
    else
        print_info "No .p10k.zsh provided — run 'p10k configure' after setup"
    fi
}

# ===========================================
# 4. Copy Configuration Files
# ===========================================

copy_configs() {
    print_header "Copying Configuration Files"

    # .zshrc
    if [ -f "$SCRIPT_DIR/configs/.zshrc" ]; then
        backup_file "$HOME/.zshrc"
        cp "$SCRIPT_DIR/configs/.zshrc" "$HOME/.zshrc"
        print_success "Copied .zshrc"
    else
        print_warning ".zshrc not found in configs/"
    fi

    # .zprofile (runs before .zshrc, needed for pyenv)
    if [ -f "$SCRIPT_DIR/configs/.zprofile" ]; then
        backup_file "$HOME/.zprofile"
        cp "$SCRIPT_DIR/configs/.zprofile" "$HOME/.zprofile"
        print_success "Copied .zprofile"
    else
        print_warning ".zprofile not found in configs/"
    fi

    # .gitconfig
    if [ -f "$SCRIPT_DIR/configs/.gitconfig" ]; then
        backup_file "$HOME/.gitconfig"
        cp "$SCRIPT_DIR/configs/.gitconfig" "$HOME/.gitconfig"

        # Set user name and email
        git config --global user.name "$GIT_NAME"
        git config --global user.email "$GIT_EMAIL"

        print_success "Copied .gitconfig (user: $GIT_NAME <$GIT_EMAIL>)"
    else
        print_warning ".gitconfig not found in configs/"
    fi

    # .tmux.conf
    if [ -f "$SCRIPT_DIR/configs/.tmux.conf" ]; then
        backup_file "$HOME/.tmux.conf"
        cp "$SCRIPT_DIR/configs/.tmux.conf" "$HOME/.tmux.conf"
        print_success "Copied .tmux.conf"
    else
        print_warning ".tmux.conf not found in configs/"
    fi

    # SSH config
    if [ -f "$SCRIPT_DIR/configs/.ssh/config" ]; then
        mkdir -p "$HOME/.ssh"
        chmod 700 "$HOME/.ssh"
        backup_file "$HOME/.ssh/config"
        cp "$SCRIPT_DIR/configs/.ssh/config" "$HOME/.ssh/config"
        chmod 600 "$HOME/.ssh/config"
        print_success "Copied SSH config"
    else
        print_warning "SSH config not found in configs/.ssh/"
    fi

    # Generate SSH key if not exists
    if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
        print_info "Generating SSH key for $GIT_EMAIL..."
        ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$HOME/.ssh/id_ed25519" -N ""
        print_success "SSH key generated"
        print_warning "Don't forget to add your SSH key to GitHub!"
        echo ""
        echo "Your public key:"
        cat "$HOME/.ssh/id_ed25519.pub"
        echo ""
    else
        print_success "SSH key already exists"
    fi

    log "Configs copied"
}

# ===========================================
# 5. Setup Python Environment
# ===========================================

setup_python() {
    print_header "Setting up Python Environment"

    # Initialize pyenv (might not be in PATH yet)
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"

    for version in "${PYTHON_VERSIONS[@]}"; do
        if pyenv versions | grep -q "$version"; then
            print_success "Python $version is already installed"
        else
            print_info "Installing Python $version (this may take a few minutes)..."
            run_logged pyenv install "$version"
            print_success "Python $version installed"
        fi
    done

    # Set global Python version
    pyenv global "$PYTHON_GLOBAL"
    print_success "Set Python $PYTHON_GLOBAL as global default"
    log "Python setup completed"
}

# ===========================================
# 6. Install pipx packages
# ===========================================

install_pipx_packages() {
    print_header "Installing pipx Packages"

    # Ensure pipx is available
    export PATH="$HOME/.local/bin:$PATH"

    for package in "${PIPX_PACKAGES[@]}"; do
        if pipx list 2>/dev/null | grep -q "package $package"; then
            if [ "$UPDATE_PACKAGES" = true ]; then
                print_info "Updating $package..."
                run_logged pipx upgrade "$package" || print_warning "Failed to update $package"
            else
                print_success "$package (already installed)"
            fi
        else
            print_info "Installing $package..."
            run_logged pipx install "$package" || print_warning "Failed to install $package"
        fi
    done

    log "pipx packages step completed"
}

# ===========================================
# 7. Setup FZF
# ===========================================

setup_fzf() {
    print_header "Setting up FZF"

    if [ -f ~/.fzf.zsh ]; then
        print_success "FZF is already configured"
    else
        print_info "Running FZF install script..."
        "$(brew --prefix)/opt/fzf/install" --all --no-bash --no-fish
        print_success "FZF configured"
    fi
}

# ===========================================
# 8. Setup Cursor IDE
# ===========================================

setup_cursor() {
    print_header "Setting up Cursor IDE"

    local cursor_config_dir="$HOME/Library/Application Support/Cursor/User"

    # Copy settings.json
    if [ -f "$SCRIPT_DIR/configs/cursor/settings.json" ]; then
        mkdir -p "$cursor_config_dir"
        backup_file "$cursor_config_dir/settings.json"
        cp "$SCRIPT_DIR/configs/cursor/settings.json" "$cursor_config_dir/settings.json"
        print_success "Copied Cursor settings.json"
    fi

    # Install extensions
    if [ -f "$SCRIPT_DIR/configs/cursor/extensions.txt" ]; then
        if command -v cursor &> /dev/null; then
            print_info "Installing Cursor extensions..."
            while IFS= read -r extension || [[ -n "$extension" ]]; do
                # Skip comments and empty lines
                [[ "$extension" =~ ^#.*$ ]] && continue
                [[ -z "$extension" ]] && continue

                print_info "Installing extension: $extension"
                cursor --install-extension "$extension" 2>/dev/null || print_warning "Could not install $extension"
            done < "$SCRIPT_DIR/configs/cursor/extensions.txt"
            print_success "Cursor extensions installed"
        else
            print_warning "Cursor CLI not found — install extensions manually or rerun after adding 'cursor' to PATH"
        fi
    fi
}

# ===========================================
# 9. Setup iTerm2
# ===========================================

setup_iterm() {
    print_header "Setting up iTerm2"

    if ! app_installed "iTerm"; then
        print_info "iTerm2 is not installed, skipping configuration"
        return
    fi

    local iterm_plist="$SCRIPT_DIR/configs/iterm2/com.googlecode.iterm2.plist"
    local target_plist="$HOME/Library/Preferences/com.googlecode.iterm2.plist"

    if [ -f "$iterm_plist" ]; then
        # Check if iTerm is running
        if pgrep -x "iTerm2" > /dev/null; then
            print_warning "iTerm2 is running. Please close it first to apply settings."
            read -p "Close iTerm2 and continue? [y/N] " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                osascript -e 'quit app "iTerm"' 2>/dev/null || true
                sleep 2
            else
                print_warning "Skipped iTerm2 setup"
                return
            fi
        fi

        backup_file "$target_plist"
        cp "$iterm_plist" "$target_plist"

        # Tell macOS to reload preferences
        defaults read com.googlecode.iterm2 &>/dev/null || true

        print_success "iTerm2 settings restored"
        print_info "Settings include: color scheme, fonts, keybindings, profiles"
    else
        print_warning "iTerm2 config not found at $iterm_plist"
    fi
}

# ===========================================
# 10. Setup tmux
# ===========================================

setup_tmux() {
    print_header "Setting up tmux"

    if [ -f "$HOME/.tmux.conf" ]; then
        print_success "tmux config already in place"
    else
        print_warning "tmux config was not copied (file missing from configs/)"
    fi

    print_info "Prefix key: C-a | Split: | and - | Reload: C-a r"
}

# ===========================================
# 11. macOS Settings
# ===========================================

configure_macos() {
    print_header "Configuring macOS Settings"

    print_info "Applying macOS preferences..."

    # Finder: show hidden files
    defaults write com.apple.finder AppleShowAllFiles -bool true

    # Finder: show all filename extensions
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true

    # Finder: show path bar
    defaults write com.apple.finder ShowPathbar -bool true

    # Finder: show status bar
    defaults write com.apple.finder ShowStatusBar -bool true

    # Disable the "Are you sure you want to open this application?" dialog
    defaults write com.apple.LaunchServices LSQuarantine -bool false

    # Keyboard: fast key repeat
    defaults write NSGlobalDomain KeyRepeat -int 2
    defaults write NSGlobalDomain InitialKeyRepeat -int 15

    # Trackpad: enable tap to click
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

    # Screenshots: save to Desktop
    defaults write com.apple.screencapture location -string "${HOME}/Desktop"

    # Screenshots: save as PNG
    defaults write com.apple.screencapture type -string "png"

    # Dock: minimize windows into application icon
    defaults write com.apple.dock minimize-to-application -bool true

    # Dock: auto-hide
    defaults write com.apple.dock autohide -bool true

    # Dock: remove delay
    defaults write com.apple.dock autohide-delay -float 0

    # Hot corners: bottom-right → Desktop
    defaults write com.apple.dock wvous-br-corner -int 4
    defaults write com.apple.dock wvous-br-modifier -int 0

    # Restart affected applications
    killall Finder &> /dev/null || true
    killall Dock &> /dev/null || true

    print_success "macOS settings configured"
    print_warning "Some changes may require a logout/restart to take effect"
    log "macOS settings applied"
}

# ===========================================
# Main
# ===========================================

main() {
    echo ""
    echo -e "${GREEN}"
    echo "  ███╗   ██╗███████╗██╗    ██╗    ██╗     ██╗███████╗███████╗"
    echo "  ████╗  ██║██╔════╝██║    ██║    ██║     ██║██╔════╝██╔════╝"
    echo "  ██╔██╗ ██║█████╗  ██║ █╗ ██║    ██║     ██║█████╗  █████╗  "
    echo "  ██║╚██╗██║██╔══╝  ██║███╗██║    ██║     ██║██╔══╝  ██╔══╝  "
    echo "  ██║ ╚████║███████╗╚███╔███╔╝    ███████╗██║██║     ███████╗"
    echo "  ╚═╝  ╚═══╝╚══════╝ ╚══╝╚══╝     ╚══════╝╚═╝╚═╝     ╚══════╝"
    echo -e "${NC}"
    echo "  dev environment setup"
    echo ""

    # Initialize log
    echo "=== Setup started at $(date) ===" > "$LOG_FILE"
    log "Script directory: $SCRIPT_DIR"

    # Ask for confirmation
    read -p "This will set up your development environment. Continue? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Setup cancelled"
        exit 0
    fi

    # Ask about updates
    echo ""
    read -p "Update existing packages to latest versions? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        UPDATE_PACKAGES=true
    fi

    # Gather user info (name, email)
    gather_user_info

    # Run setup steps
    install_homebrew
    install_brew_packages
    install_oh_my_zsh
    copy_configs
    setup_python
    install_pipx_packages
    setup_fzf
    setup_cursor
    setup_iterm
    setup_tmux

    # macOS settings (optional)
    echo ""
    read -p "Apply macOS settings (Finder, Dock, keyboard)? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        configure_macos
    fi

    # Done!
    print_header "Setup Complete!"

    echo "Next steps:"
    echo ""
    echo "1. Restart your terminal or run: source ~/.zshrc"
    echo "2. Configure Powerlevel10k: p10k configure"
    echo "3. Add your SSH key to GitHub:"
    echo "   - Copy: pbcopy < ~/.ssh/id_ed25519.pub"
    echo "   - Go to: https://github.com/settings/keys"
    echo "4. Login to apps: Docker, etc."
    echo "5. Set iTerm2 font to 'MesloLGS NF' (Preferences → Profiles → Text)"
    echo ""
    echo "Log file: $LOG_FILE"
    echo ""

    log "Setup completed successfully"
    print_success "Happy coding!"
}

# Run main function
main "$@"
