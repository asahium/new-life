# AGENTS.md

Dotfiles and bootstrap script for a fresh macOS (Apple Silicon) machine. There is no build and no test suite; the deliverable is `setup.sh` plus the files it installs.

## Layout

- `setup.sh` — the only entry point. Bash, `set -e`. Steps run in the order listed in `main()`.
- `Brewfile` — every Homebrew tap, formula and cask the script installs.
- `configs/` — files copied into `$HOME`. Each one has a matching copy step in `setup.sh`:

| Repo path | Installed to | Step |
|---|---|---|
| `configs/.zshrc`, `.zprofile`, `.gitconfig`, `.tmux.conf`, `.ssh/config` | `~/` | `copy_configs` |
| `configs/.p10k.zsh` | `~/.p10k.zsh` | `install_oh_my_zsh` |
| `configs/ghostty/config` | `~/.config/ghostty/config` | `setup_ghostty` |
| `configs/agterm/{ghostty,keymap}.conf` | `~/.config/agterm/` | `setup_agterm` |
| `configs/nvim/init.lua` | `~/.config/nvim/init.lua` | `setup_neovim` |
| `configs/cursor/settings.json`, `extensions.txt` | `~/Library/Application Support/Cursor/User/` | `setup_cursor` |

- `README.md` — user-facing docs. It lists every package and app, so keep it in sync with `Brewfile`.

## How `setup.sh` reads the Brewfile

It does not run `brew bundle`. It greps the Brewfile and pulls names out with `sed`, so every entry must sit on its own line starting at column 0:

```ruby
tap "owner/name"
brew "formula"               # comment allowed after the closing quote
cask "token"                 # or "owner/tap/token"
```

Indented lines are silently ignored, and extra arguments such as `brew "x", args: [...]` are dropped: only the quoted name is used.

Casks are skipped when `/Applications/<App>.app` already exists. `<App>` comes from the `case "$cask"` mapping in `install_brew_packages`, falling back to the cask token. Add a mapping whenever the `.app` name differs from the token, and always for tap-qualified casks (`owner/tap/token`), because the fallback would use the full path.

## Adding things

- **Package or app:** add a line to `Brewfile` in the matching section, add a cask→app mapping if needed, and update the README lists.
- **Config file:** put it under `configs/<tool>/`, copy it in a `setup_<tool>` function using `backup_file` before `cp`, call the function from `main()`, and add a row to the README structure tree.
- **Python or pipx tools:** edit `PYTHON_VERSIONS`, `PYTHON_GLOBAL` and `PIPX_PACKAGES` at the top of `setup.sh`.

## Conventions in `setup.sh`

- Wrap commands with `run_logged` so their output goes to `setup.log` (gitignored). Report status with `print_success`, `print_info`, `print_warning` and `print_error`.
- A failed optional install should warn and continue (`|| print_warning ...`). Never let it abort the run.
- Every prompt must respect `--yes` (`ASSUME_YES`), and steps must stay idempotent: rerunning the script skips what is already installed.
- The package loops are `grep ... | while read`, so stdin inside them is the Brewfile. A prompt there must read from `/dev/tty`, as `ask_install` does.
- Check syntax with `bash -n setup.sh` after editing.

## External pieces

- **`asahium/tap`** lives in a separate repo, [asahium/homebrew-tap](https://github.com/asahium/homebrew-tap), and holds the `suzuri`, `inni` and `kveikur` casks. Some of its casks have `*flight` blocks, so Homebrew refuses to load any cask from it until `brew trust --tap asahium/tap` runs; `setup.sh` does this right after tapping. Lint changes there with `brew style --cask asahium/tap/<token>` and `brew fetch --cask asahium/tap/<token>`.
- **agterm** ([umputun/agterm](https://github.com/umputun/agterm)) is installed from `umputun/apps`. Its agent skill and status hooks are installed from the app's Help menu, not by this repo.

## Neovim config (`configs/nvim/init.lua`)

Single file using lazy.nvim. Keep these choices in place:

- `nvim-treesitter` is pinned to `branch = "master"`. The default `main` branch is a rewrite without `nvim-treesitter.configs`.
- Servers built from source by mason are only auto-installed when their toolchain exists (`needs_toolchain`, for example `gopls` requires `go`).
- The Perl, Python 3, Ruby and Node providers are disabled on purpose.

Smoke test without touching `~/.config/nvim`: `nvim --headless -u configs/nvim/init.lua +qa`.

## Working on this machine

- The user's interactive zsh aliases `rm` to `trash`, `ls` to `eza`, `cat` to `bat`, `grep` to `rg` and `find` to `fd`, and `cp` prompts before overwriting. In shell commands use `/bin/rm`, `/bin/ls` and `/bin/cp -f`.
- Don't overwrite live files under `~/` or `~/.config/` unless asked. Edit the copy in `configs/` and let `setup.sh` install it.
- Work happens directly on `master`. Write short, imperative commit messages and leave unrelated working-tree changes out of commits.
