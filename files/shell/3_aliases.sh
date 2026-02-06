# UPDATE
alias update-brew="brew update && brew upgrade && brew autoremove && brew cleanup"
alias update-dnf="sudo dnf update -y && sudo dnf autoremove"
alias update-apt="sudo apt update && sudo apt upgrade -y && sudo apt autoremove"

# NAVIGATION (.. ... ll l la already defined by oh-my-zsh)

# GIT
alias g="git"
alias gs="git status"
alias gp="git push"
alias gl="git pull"
alias gd="git diff"
alias gc="git commit"
alias gco="git checkout"
alias glog="git log --oneline --graph --decorate -15"

# TOOLS
alias tf="terraform"
alias tg="terragrunt"
alias cat="bat --paging=never 2>/dev/null || cat"

# SHORTCUTS
alias reload="source ~/.zshrc"
alias zshrc="\$EDITOR ~/.zshrc"
alias dotfiles="cd ~/.dotFiles"
alias ip="curl -s ifconfig.me"
alias ports="lsof -iTCP -sTCP:LISTEN -n -P"
