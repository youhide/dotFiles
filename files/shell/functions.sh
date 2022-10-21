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
    if grep -q "\[profile $1\]" ~/.aws/config; then
      export AWS_PROFILE=${1}
      echo "AWS command line environment set to [${1}]"
    else
      echo "AWS profile [${1}] not found."
      echo "Please choose from an existing profile:"
      grep "\[profile" ~/.aws/config
      echo "Or create a new one."
    fi
  fi
}

function awsclear() {
  unset AWS_PROFILE
  echo "AWS command line environment cleared."
}
