# dotFiles

Personal dotFiles managed with [hideDot](https://github.com/youhide/hideDot).

## Install

```bash
brew tap youhide/homebrew-youhide
brew install hidedot

git clone https://github.com/youhide/dotFiles.git ~/.dotFiles
cd ~/.dotFiles
hidedot --dry-run  # preview changes
hidedot            # apply
```

## What's included

| File | Description |
|---|---|
| `zshrc` | Entry point — sources all shell scripts |
| `zprofile` | Login shell config |
| `tmux.conf` | Tmux configuration (Dracula, TPM, true color) |
| `vimrc` | Vim configuration (fallback for `sudo vi`) |
| `nvim/` | Neovim configuration (lazy.nvim, Dracula, LSP) |
| `iterm2/` | iTerm2 dynamic profile for the `v` launcher |
| `npmrc` | NPM registries config |
| `hushlogin` | Suppress login banner |

### Shell modules (`files/shell/`)

| File | Purpose |
|---|---|
| `1_oh-my-zsh.sh` | Oh My Zsh setup (theme: robbyrussell, plugins: pass, kubectl) |
| `2_start_functions.sh` | ASCII art + random startup phrase |
| `3_aliases.sh` | Custom aliases (git, tools, shortcuts) |
| `4_paths.sh` | Brew + Python PATH setup (cached) |
| `5_exports.sh` | Lazy-loaded secrets via `pass`, lazy NVM, `$EDITOR` |
| `6_completion.sh` | Completions + autosuggestions (terraform/tofu/terragrunt lazy loaded) |
| `7_extra.sh` | iTerm2 shell integration |
| `8_colors.sh` | Terminal color variables |
| `9_functions.sh` | Utility functions (aws, update, mkcd, extract, `v`) |

## Neovim

Lua config in `files/nvim/`, symlinked to `~/.config/nvim`. Dracula theme
matching the iTerm2 profile, LSP for TypeScript/Rust/Go/Python/web, treesitter
highlighting, telescope, git signs and VSCode-style keybindings.

| File | Purpose |
|---|---|
| `init.lua` | Leader + module bootstrap |
| `lua/config/options.lua` | Editor options (clipboard, mouse, indent, undo) |
| `lua/config/keymaps.lua` | Ctrl and Cmd shortcuts, leader mappings |
| `lua/config/autocmds.lua` | Yank highlight, cursor restore, autosave on focus lost |
| `lua/config/lazy.lua` | Plugin manager bootstrap |
| `lua/plugins/*.lua` | One file per area (lsp, completion, telescope, ui, ...) |

### Shortcuts

`Ctrl` works everywhere. `Cmd` works in the dedicated "Neovim" iTerm2 profile
(opened by `v`), because the profile translates it into escape sequences that
Neovim understands. Inside tmux, use `Ctrl`.

```
Ctrl+P  / Cmd+P             find file       Ctrl+S / Cmd+S   save
Ctrl+Shift+F / Cmd+Shift+F  grep project    Ctrl+/ / Cmd+/   comment
Ctrl+B  / Cmd+B             file explorer   Ctrl+A / Cmd+A   select all
Ctrl+D  / Cmd+D             multi-cursor    Ctrl+\           terminal
Alt+Up/Down                 move line       Shift+H/Shift+L  prev/next buffer
Ctrl+h/j/k/l                move across nvim splits and tmux panes
gd  K  grn  gra  grr        definition, hover, rename, code action, references
<Space>                     leader - press it to see every mapping (which-key)
```

`Cmd+C` / `Cmd+V` stay iTerm2's native copy and paste.

### Requirements beyond Neovim 0.12

```bash
brew install ripgrep fd lazygit tree-sitter-cli bat
```

`ripgrep` is required for project search, and `tree-sitter-cli` for building
treesitter parsers. Node comes from nvm -- Neovim puts it on `PATH` itself,
since nvm is a lazy shell function that child processes never inherit.

## Performance

- Cached `brew --prefix` and Python user base path
- Lazy-loaded NVM (nvm/node/npm/npx/pnpm)
- Lazy-loaded secrets (`load_secrets` / `unload_secrets` / `list_secrets`)
- Lazy-loaded terraform/tofu/terragrunt completions
- Daily `compinit` cache (`compinit -C`)

## Custom aliases

```
g     → git              gs    → git status        gp    → git push
gl    → git pull         gd    → git diff          gc    → git commit
gco   → git checkout     glog  → git log (pretty)
tf    → terraform        tg    → terragrunt
cat   → bat              reload → source ~/.zshrc
dotfiles → cd ~/.dotFiles  ip  → public IP
ports → listening ports    v     → nvim in a new iTerm2 window
```

### `v` — Neovim in its own window

Works like `code .`: opens Neovim in a new iTerm2 window using the dedicated
"Neovim" profile (Dracula, no transparency, Cmd keys enabled).

```bash
v              # current directory
v .            # current directory
v src/app.ts   # that file
v ~/Git/foo    # that directory
```

## Secrets management

Secrets are **not loaded on startup**. Use these commands:

```bash
load_secrets    # decrypt and export all secrets from pass
unload_secrets  # clear all secrets from env
list_secrets    # show which secrets are loaded (✔/✘)
```

To add a new secret, edit `_SECRET_ENTRIES` in `files/shell/5_exports.sh`:

```bash
_SECRET_ENTRIES=(
  "MY_NEW_TOKEN:path/in/pass/store"
  ...
)
```

## Requirements

- [hideDot](https://github.com/youhide/hideDot)
- [Oh My Zsh](https://ohmyz.sh/)
- [pass](https://www.passwordstore.org/) (for secrets)
- [Homebrew](https://brew.sh/)
- [Neovim](https://neovim.io/) 0.12+
- [TPM](https://github.com/tmux-plugins/tpm) — `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`

`files/iterm2/com.googlecode.iterm2.plist` is a backup of the full iTerm2
preferences. It is not symlinked (iTerm2 rewrites it constantly); import it
manually via Settings → General → Preferences.

## License

MIT © [Youri T. K. K. Mattar](https://github.com/youhide)
