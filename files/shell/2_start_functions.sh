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
