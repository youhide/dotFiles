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
