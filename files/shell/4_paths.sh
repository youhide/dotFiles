if type brew &>/dev/null
then
  eval "$($(brew --prefix)/bin/brew shellenv)"
else
  case "$OSTYPE" in
    linux*)   eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" ;;
    darwin*)  eval "$($(brew --prefix)/bin/brew shellenv)" || eval "$(/opt/homebrew/bin/brew shellenv)" ;; 
    win*)     echo "Windows" ;;
    *)        echo "unknown: $OSTYPE" ;;
  esac
fi

PATH="$(python3 -m site --user-base)/bin:${PATH}"
