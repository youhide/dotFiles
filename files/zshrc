RED="\033[1;31m"
GREEN="\033[1;32m"
NOCOLOR="\033[0m"

ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#ff00ff,bg=244,bold,underline"

YODA=$(yoda-quotes)

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

  autoload -Uz compinit
  compinit
fi

source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh

echo ${GREEN}${YODA}${NOCOLOR} 
