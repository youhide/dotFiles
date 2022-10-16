ZSH_AUTOSUGGEST_USE_ASYNC=1

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# case $- in *i*)
#     if [ -z "$TMUX" ]
#     then
#         # tmux attach -t 0 || tmux new -s 0
#         exec tmux attach
#     fi
# esac
