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
alias cat="bat --paging=never"
alias tf="terraform"
alias tg="terragrunt"

# SHORTCUTS
alias reload="source ~/.zshrc"
alias zshrc="\$EDITOR ~/.zshrc"
alias dotfiles="cd ~/.dotFiles"
alias dotfiles_code="code ~/.dotFiles"
alias dotfiles_nvim="nvim ~/.dotFiles"
alias vi="nvim"
alias vim="nvim"
alias ip="curl -s ifconfig.me"
alias ports="lsof -iTCP -sTCP:LISTEN -n -P"

# Free Ctrl+S / Ctrl+Q in the shell so nvim can use Ctrl+S to save.
# (nvim itself puts the tty in raw mode, but the shell would freeze.)
[[ -t 0 ]] && stty -ixon
