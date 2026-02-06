# Detect brew prefix without running brew (fast)
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Cache BREW_PREFIX to avoid calling `brew --prefix` repeatedly
export BREW_PREFIX="${HOMEBREW_PREFIX:-$(brew --prefix 2>/dev/null)}"

# Cache python user base path (avoid calling python3 every shell startup)
if [[ -f "$HOME/.cache/python_user_base" ]]; then
  PATH="$(cat "$HOME/.cache/python_user_base")/bin:${PATH}"
else
  _python_base="$(python3 -m site --user-base 2>/dev/null)"
  if [[ -n "$_python_base" ]]; then
    mkdir -p "$HOME/.cache"
    echo "$_python_base" > "$HOME/.cache/python_user_base"
    PATH="${_python_base}/bin:${PATH}"
  fi
  unset _python_base
fi
