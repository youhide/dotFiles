# --- Oh My Zsh Configuration ---
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

# Disable auto-updates on startup (run `omz update` manually)
zstyle ':omz:update' mode disabled

# Plugins (keep minimal for speed)
# git aliases are defined in 3_aliases.sh, no need for the git plugin
plugins=(pass kubectl)

# Performance
ZSH_AUTOSUGGEST_USE_ASYNC=1

source "$ZSH/oh-my-zsh.sh"
