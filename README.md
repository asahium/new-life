# new-life

Automated dev environment setup for a fresh macOS machine.

## Quick Start

```bash
git clone https://github.com/asahium/new-life.git
cd new-life
chmod +x setup.sh
./setup.sh
```

The script will prompt for your name and email (used for git config and SSH key generation).

## What's Included

### CLI Tools

| Category | Packages |
|----------|----------|
| Essential | git, gh, wget, curl, jq, yq |
| Modern replacements | bat, eza, fd, ripgrep, fzf, zoxide |
| Monitoring | btop, htop |
| Files | tree, trash, nnn |
| Dev | tmux, neovim, lazygit, delta |
| Python | pyenv, pyenv-virtualenv, pipx |
| Node | node, nvm |

### Apps

iTerm2, Ghostty, Kitty, Cursor, Zed, Docker, JetBrains Toolbox, Obsidian, Telegram, Zoom, Brave, VLC, OBS

> Already installed apps will be skipped. Missing ones will prompt for confirmation.

### Shell

- Oh My Zsh + Powerlevel10k
- Plugins: git, autosuggestions, syntax-highlighting, fzf, docker, zoxide
- Nerd Fonts (Meslo, Fira Code, JetBrains Mono)

### Python

- pyenv with 3.11, 3.12
- pipx: poetry, black, ruff, mypy, isort, wandb, jupyter, jupyterlab, pytest, pre-commit, httpie, tldr

## Structure

```
├── setup.sh                          # Main setup script
├── Brewfile                          # Homebrew packages
├── configs/
│   ├── .zshrc                        # Zsh config (Oh My Zsh, aliases, env)
│   ├── .zprofile                     # Login shell config (Homebrew, pyenv)
│   ├── .gitconfig                    # Git config (delta, aliases, SSH)
│   ├── .tmux.conf                    # tmux config (C-a prefix, Nord theme)
│   ├── .ssh/
│   │   └── config                    # SSH config (Keychain, GitHub, GitLab)
│   ├── cursor/
│   │   ├── settings.json             # Cursor IDE settings
│   │   └── extensions.txt            # Cursor extensions list
│   └── iterm2/
│       └── com.googlecode.iterm2.plist
└── README.md
```

## Configs

### .zshrc

Oh My Zsh with Powerlevel10k, pyenv/nvm init, zoxide, fzf (Nord colors), and aliases.

### .gitconfig

Delta as diff pager (side-by-side, Nord theme), auto-rebase, SSH for GitHub, useful aliases (`lg`, `undo`, `amend`, `cleanup`).

### .tmux.conf

`C-a` prefix, `|` and `-` splits, vim-style navigation, mouse support, Nord status bar.

### SSH

macOS Keychain integration, GitHub/GitLab hosts, ed25519 key.

## Aliases

```bash
# git
gs gp gpl gcm gaa lg glog gd gco gb gst
gc "message"  # git add --all && git commit

# files
ll lt la l cat (bat) tree (eza)

# python
venv activate py ipy

# docker
d dc dps dprune

# system
reload ..  ... mkcd extract port
```

## Customization

### Packages

Edit `Brewfile` to add/remove Homebrew packages.

### Python versions

Edit `PYTHON_VERSIONS` and `PYTHON_GLOBAL` at the top of `setup.sh`:

```bash
PYTHON_VERSIONS=("3.11.11" "3.12.8")
PYTHON_GLOBAL="3.12.8"
```

### pipx tools

Edit `PIPX_PACKAGES` array at the top of `setup.sh`.

### Git identity

Either edit `GIT_NAME` and `GIT_EMAIL` at the top of `setup.sh`, or leave them empty to be prompted during setup.

## After Setup

1. `source ~/.zshrc`
2. `p10k configure` — set up your Powerlevel10k prompt
3. Add SSH key to GitHub: `pbcopy < ~/.ssh/id_ed25519.pub`
4. Set iTerm2 font to `MesloLGS NF` (Preferences → Profiles → Text)

## Logging

All command output is saved to `setup.log` in the project directory for debugging.

## License

MIT
