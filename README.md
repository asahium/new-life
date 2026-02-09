# new-life

Automated dev environment setup for a fresh machine.

## Quick Start

```bash
git clone https://github.com/asahium/new-life.git
cd new-life
chmod +x setup.sh
./setup.sh
```

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
- Plugins: git, autosuggestions, syntax-highlighting, fzf, docker
- Nerd Fonts

### Python

- pyenv with 3.11, 3.12
- pipx: poetry, black, ruff, mypy, wandb, jupyter, pytest, pre-commit

## Structure

```
├── setup.sh
├── Brewfile
├── configs/
│   ├── .zshrc
│   ├── .p10k.zsh      # Powerlevel10k theme config
│   ├── .gitconfig
│   ├── cursor/
│   ├── iterm2/
│   └── .ssh/config
└── README.md
```

## Configs

### .zshrc
Oh My Zsh, Powerlevel10k, pyenv/nvm init, aliases

### .gitconfig
Aliases, delta diffs, auto-rebase, SSH for GitHub

### SSH
Keychain integration, GitHub/GitLab hosts

## Aliases

```bash
# git
gs gp gpl gcm gaa lg glog

# files
ll lt cat (bat)

# python
venv activate

# docker
d dc dps dprune
```

## After Setup

1. `source ~/.zshrc`
2. `p10k configure`
3. Add SSH key to GitHub: `pbcopy < ~/.ssh/id_ed25519.pub`
4. Set iTerm2 font to `MesloLGS NF`

## Customization

Edit `Brewfile` to add/remove packages.

Edit `setup.sh` → `python_versions` array for different Python versions.

Edit `install_pipx_packages` for different global tools.

## License

MIT
