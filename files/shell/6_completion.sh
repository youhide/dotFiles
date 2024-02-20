if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

  autoload -Uz compinit
  compinit
fi

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C $(brew --prefix)/bin/terraform terraform
complete -o nospace -C $(brew --prefix)/bin/tofu tofu
complete -o nospace -C $(brew --prefix)/bin/terragrunt terragrunt
