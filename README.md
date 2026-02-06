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
| `tmux.conf` | Tmux configuration |
| `vimrc` | Vim configuration |
| `npmrc` | NPM registries config |
| `hushlogin` | Suppress login banner |

### Shell modules (`files/shell/`)

| File | Purpose |
|---|---|
| `1_oh-my-zsh.sh` | Oh My Zsh setup (theme: robbyrussell, plugins: pass, kubectl) |
| `2_start_functions.sh` | ASCII art + random startup phrase |
| `3_aliases.sh` | Custom aliases (git, tools, shortcuts) |
| `4_paths.sh` | Brew + Python PATH setup (cached) |
| `5_exports.sh` | Lazy-loaded secrets via `pass`, lazy NVM |
| `6_completion.sh` | Completions + autosuggestions (terraform/tofu/terragrunt lazy loaded) |
| `7_extra.sh` | iTerm2 shell integration |
| `8_colors.sh` | Terminal color variables |
| `9_functions.sh` | Utility functions (aws, update, mkcd, extract) |

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
ports → listening ports
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

## License

MIT © [Youri T. K. K. Mattar](https://github.com/youhide)
