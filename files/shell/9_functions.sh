function awsuse() {
  if [ -z "$1" ]; then
    echo "No environment supplied"
  else
    if findStringInFile ~/.aws/config $1; then
      export AWS_PROFILE=${1}
      echo "AWS command line environment set to ${GREEN}[${1}]${NOCOLOR}"
      aws sso login
    else
      echo "AWS profile ${RED}[${1}]${NOCOLOR} not found."
      echo "Please choose from an existing profile:"
      grep "\[profile" ~/.aws/config
      echo "Or create a new one."
    fi
  fi
}

function awsclear() {
  unset AWS_PROFILE
  echo "AWS command line environment cleared."
  aws sso logout
  echo "AWS SSO session cleared."
}

function findStringInFile() {
  if [ -z "$1" ]; then
    echo "No file supplied"
  else
    if [ -z "$2" ]; then
      echo "No string supplied"
    else
      if grep -q "$2" $1; then
        echo "Found ${GREEN}$2${NOCOLOR} in ${YELLOW}$1${NOCOLOR}"
        return 0
      else
        echo "Did not find ${RED}$2${NOCOLOR} in ${RED}$1${NOCOLOR}"
        return 1
      fi
    fi
  fi
}

function update() {
  case "$OSTYPE" in
    linux*)   update-brew && updateLinux ;;
    darwin*)  update-brew ;; 
    win*)     echo "Windows" ;;
    *)        echo "unknown: $OSTYPE" ;;
  esac
}

function detectLinuxDistribution() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo $NAME
  elif type lsb_release >/dev/null 2>&1; then
    lsb_release -si
  elif [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    echo $DISTRIB_ID
  elif [ -f /etc/debian_version ]; then
    echo Debian
  elif [ -f /etc/fedora-release ]; then
    echo Fedora
  elif [ -f /etc/redhat-release ]; then
    echo Red Hat Enterprise Linux
  else
    echo "Unsupported distribution"
  fi
}

function updateLinux() {
  if [[ "$(detectLinuxDistribution)" == *"Ubuntu"* ]]; then
    update-apt
  elif [[ "$(detectLinuxDistribution)" == *"Fedora"* ]]; then
    update-dnf
  else
    echo "Unsupported OS"
  fi
}
