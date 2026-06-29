# new-life

Automated dev environment setup for a fresh macOS machine.

## Quick Start

```bash
git clone https://github.com/asahium/new-life.git
cd new-life
chmod +x setup.sh
./setup.sh
```

The script requires a non-empty name and a valid email (used for git config and SSH key generation).

## What's Included

### CLI Tools

| Category | Packages |
|----------|----------|
| Essential | git, gh, wget, curl, jq, yq |
| Modern replacements | bat, eza, fd, ripgrep, fzf, zoxide |
| Monitoring | btop, htop, mtop |
| Files | tree, trash, nnn |
| Dev | tmux, neovim, lazygit, delta |
| Python | pyenv, pyenv-virtualenv, pipx |
| Node | node, nvm |
| Utilities | mole, tldr, watch, mas |

### Apps

Ghostty, agterm, Cursor, Zed, Docker, JetBrains Toolbox, Obsidian, Zoom, Brave, VLC, OBS, The Unarchiver, Maccy

> Already installed apps will be skipped. Missing ones will prompt for confirmation.
> `setup.sh` does not apply macOS Finder/Dock/keyboard defaults.

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
│   ├── .p10k.zsh                     # Powerlevel10k prompt config
│   ├── .ssh/
│   │   └── config                    # SSH config (Keychain, GitHub, GitLab)
│   ├── ghostty/
│   │   └── config                    # Ghostty terminal config
│   ├── agterm/
│   │   ├── ghostty.conf              # agterm-scoped terminal config
│   │   └── keymap.conf               # agterm keybindings + custom commands
│   ├── nvim/
│   │   └── init.lua                  # Neovim config (lazy.nvim, LSP, Nord)
│   └── cursor/
│       ├── settings.json             # Cursor IDE settings
│       └── extensions.txt            # Cursor extensions list
└── README.md
```

## Configs

### .zshrc

Oh My Zsh with Powerlevel10k, pyenv/nvm init, zoxide, fzf (Nord colors), and aliases.

### .gitconfig

Delta as diff pager (side-by-side, Nord theme), auto-rebase, SSH for GitHub, useful aliases (`lg`, `undo`, `amend`, `cleanup`).

### .tmux.conf

`C-a` prefix, `|` and `-` splits, vim-style navigation, mouse support, Nord status bar.

### Ghostty

Nord theme, SAND keybindings, quick terminal hotkey.

### agterm

[agterm](https://github.com/umputun/agterm) is a native macOS terminal for agentic flow — it organizes shells into named workspaces so several AI-agent sessions run side by side. It embeds Ghostty's engine (libghostty) for the actual terminal work.

- `configs/agterm/ghostty.conf` — agterm-scoped terminal options (always loaded, never read by standalone Ghostty.app). Font/theme/opacity are managed in **Settings (Cmd+,)** and win over this file.
- `configs/agterm/keymap.conf` — kitty-flavored keymap: built-in rebinds plus custom shell commands (Lazygit, open in Cursor/Zed, nnn, btop).

**Usage:**

- New session `⌘N`, new workspace `⇧⌘N`, open directory `⌘O`
- Split a session `⌘D`, scratch overlay `⌘J`, quick terminal `` ⌃` ``, in-terminal search `⌘F`
- Session palette `⌃P`, action palette `⌃⇧P`, custom commands `⌃⇧O`, MRU switch `⌃Tab`
- Jump between sessions needing attention `⌃⌥↑/↓`
- Drive it from scripts/agents with the bundled `agtermctl` CLI (e.g. `agtermctl session new --cwd .`, `agtermctl tree`). The cask installs `agtermctl` automatically.
- To let an agent control it, install the agent skill and status hooks from the app's **Help** menu.

### Neovim

Modern single-file config (`configs/nvim/init.lua`) built on [lazy.nvim](https://github.com/folke/lazy.nvim), themed with Nord to match the rest. Leader key is `<Space>`.

Included plugins: Treesitter, Telescope (fuzzy finder), LSP via mason (lua, python/pyright+ruff, ts, go, rust, bash, json, yaml), nvim-cmp completion, conform.nvim (format on save), gitsigns, neo-tree, lualine, which-key, Comment, autopairs, surround, indent guides, todo-comments.

**Usage:**

- First `nvim` launch auto-installs lazy.nvim and all plugins — let it finish, then restart. Run `:checkhealth` to verify, `:Lazy` to manage plugins, `:Mason` to manage LSP servers/formatters.
- Press `<Space>` and wait to see all keybindings (which-key popup).

Key mappings:

```text
# files / search (Telescope)
<Space>ff  find files        <Space>fg  live grep
<Space>fb  buffers           <Space>fr  recent files
<Space>e   file explorer (neo-tree toggle)

# LSP
gd  definition   gr  references   K  hover docs
<Space>rn rename   <Space>ca code action
[d / ]d  prev/next diagnostic

# git (gitsigns)
]h / [h  next/prev hunk
<Space>hs stage   <Space>hr reset   <Space>hp preview   <Space>hb blame

# editing
gcc  comment line   gc (visual) comment selection
<Space>cf format buffer   <Space>w save   <Space>q quit
J / K (visual) move lines up/down
```

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

## Logging

All command output is saved to `setup.log` in the project directory for debugging.

## License

MIT
