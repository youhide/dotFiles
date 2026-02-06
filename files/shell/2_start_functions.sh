function hideascii() {
  echo "${GREEN}"
  cat << "EOF"
  .__    .__    .___     ________          __   
  |  |__ |__| __| _/____ \_____  \  __ ___/  |_ 
  |  |  \|  |/ __ |/ __ \ /   |   \|  |  \   __\
  |   Y  \  / /_/ \  ___//    |    \  |  /|  |  
  |___|  /__\____ |\___  >_______  /____/ |__|  
       \/        \/    \/        \/        
EOF
  echo "${NOCOLOR}"
}

function startphrase() {
  local file=~/.dotFiles/files/phrases.md
  [[ -f "$file" ]] || return 0
  local count=$(wc -l < "$file")
  local line=$(( RANDOM % count + 1 ))
  echo "${PURPLE}$(sed -n "${line}p" "$file")${NOCOLOR}"
}
