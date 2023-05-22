if type brew &>/dev/null
then
  eval "$($(brew --prefix)/bin/brew shellenv)"
else
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

PATH="$(python3 -m site --user-base)/bin:${PATH}"
