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

function startphrase() {
  # target file
  file=~/.dotFiles/files/phrases.md

  # count lines (number of phrases)
  COUNT=$(wc -l < "$file")

  # Generate a random number using bash RANDOM and modulo operation
  RANDPHRASE=$(( RANDOM % COUNT + 1 ))

  # echo "phrase number: $RANDPHRASE"

  PHRASE=$(sed -n "${RANDPHRASE}p" $file)

  # print the line number "RANDPHRASE"
  echo ${PURPLE}${PHRASE}${NOCOLOR}
}
