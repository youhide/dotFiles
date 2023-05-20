if type brew &>/dev/null
then
  eval "$($(brew --prefix)/bin/brew shellenv)"
else
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
