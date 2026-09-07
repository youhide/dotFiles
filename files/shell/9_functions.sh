function awsuse() {
  if [[ -z "$1" ]]; then
    echo "Usage: awsuse <profile>"
    echo "Available profiles:"
    grep "\[profile" ~/.aws/config 2>/dev/null || echo "  No profiles found."
    return 1
  fi

  if grep -q "$1" ~/.aws/config 2>/dev/null; then
    export AWS_PROFILE="$1"
    echo "AWS profile set to ${GREEN}[${1}]${NOCOLOR}"
    aws sso login
  else
    echo "AWS profile ${RED}[${1}]${NOCOLOR} not found."
    echo "Available profiles:"
    grep "\[profile" ~/.aws/config
  fi
}

function awsclear() {
  unset AWS_PROFILE
  echo "AWS profile cleared."
  aws sso logout
  echo "AWS SSO session cleared."
}

function update() {
  case "$OSTYPE" in
    linux*)   _update_linux && update-brew ;;
    darwin*)  update-brew ;;
    *)        echo "Unsupported OS: $OSTYPE" ;;
  esac
}

function _update_linux() {
  local distro
  if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    distro="$NAME"
  elif command -v lsb_release &>/dev/null; then
    distro="$(lsb_release -si)"
  else
    echo "Unsupported distribution"
    return 1
  fi

  case "$distro" in
    *Ubuntu*|*Debian*)  update-apt ;;
    *Fedora*)           update-dnf ;;
    *)                  echo "Unsupported distribution: $distro"; return 1 ;;
  esac
}

function mkcd() {
  mkdir -p "$1" && cd "$1"
}

function extract() {
  if [[ ! -f "$1" ]]; then
    echo "'$1' is not a valid file."
    return 1
  fi
  case "$1" in
    *.tar.bz2) tar xjf "$1" ;;
    *.tar.gz)  tar xzf "$1" ;;
    *.tar.xz)  tar xJf "$1" ;;
    *.bz2)     bunzip2 "$1" ;;
    *.gz)      gunzip "$1" ;;
    *.tar)     tar xf "$1" ;;
    *.tbz2)    tar xjf "$1" ;;
    *.tgz)     tar xzf "$1" ;;
    *.zip)     unzip "$1" ;;
    *.7z)      7z x "$1" ;;
    *)         echo "Cannot extract '$1'"; return 1 ;;
  esac
}

# Open Neovim in its own iTerm2 window, using the dedicated "Neovim" profile
# (Dracula, no transparency, Cmd keys wired up). Works like `code .`.
#   v              -> current directory
#   v .            -> current directory
#   v src/app.ts   -> that file, cwd = its directory
#   v ~/Git/foo    -> that directory
function v() {
  local target="${1:-.}" dir file
  if [[ -d "$target" ]]; then
    dir="${target:A}"; file=""
  else
    dir="${target:A:h}"; file="${target:A:t}"
  fi
  [[ -d "$dir" ]] || { print -u2 "v: no such directory: $dir"; return 1 }

  # iTerm2 only rereads DynamicProfiles when the directory itself changes, and
  # ours is a symlink into the dotfiles. If the profile went missing, nudge the
  # directory and give iTerm2 a moment before giving up.
  local dp="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
  if ! /usr/bin/defaults read com.googlecode.iterm2 "New Bookmarks" 2>/dev/null \
       | grep -q "Name = Neovim;"; then
    touch "$dp" 2>/dev/null
    sleep 1
  fi

  # The session is a login shell (the profile sets no custom command), so this
  # line is parsed by zsh -- ${(q)} quoting handles spaces and quotes in paths.
  # `exec` replaces the shell with nvim, so closing nvim closes the window.
  local line="cd ${(q)dir} && exec nvim"
  if [[ -n "$file" ]]; then
    line+=" -- ${(q)file}"
  else
    line+=" ."
  fi

  osascript - "$line" >/dev/null <<'OSA' || {
on run argv
  tell application "iTerm2"
    activate
    set w to (create window with profile "Neovim")
    tell current session of w to write text (item 1 of argv)
  end tell
end run
OSA
    print -u2 "v: could not open the 'Neovim' iTerm2 profile."
    print -u2 "   Restart iTerm2 (it reloads profiles on launch), or check:"
    print -u2 "   $dp/nvim.json"
    return 1
  }
}
compdef _files v 2>/dev/null
