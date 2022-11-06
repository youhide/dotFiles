function hideascii() {
echo ${GREEN}
cat << "EOF"
  .__    .__    .___     ________          __   
  |  |__ |__| __| _/____ \_____  \  __ ___/  |_ 
  |  |  \|  |/ __ |/ __ \ /   |   \|  |  \   __\
  |   Y  \  / /_/ \  ___//    |    \  |  /|  |  
  |___|  /__\____ |\___  >_______  /____/ |__|  
       \/        \/    \/        \/        
EOF
echo ${NOCOLOR}
}

function yodaquote() {
  echo ${PURPLE}$(yoda-quotes)${NOCOLOR} 
}

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
