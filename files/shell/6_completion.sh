# Use cached BREW_PREFIX instead of calling brew --prefix each time
if [[ -n "$BREW_PREFIX" ]]; then
  FPATH="${BREW_PREFIX}/share/zsh/site-functions:${FPATH}"

  autoload -Uz compinit
  # Only regenerate completion dump once a day
  if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
    compinit
  else
    compinit -C  # skip security check, much faster
  fi

  # Autosuggestions
  [[ -f "${BREW_PREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
    source "${BREW_PREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# Lazy load terraform/tofu/terragrunt completions
function terraform() {
  unset -f terraform
  autoload -U +X bashcompinit && bashcompinit
  complete -o nospace -C "${BREW_PREFIX}/bin/terraform" terraform
  terraform "$@"
}

function tofu() {
  unset -f tofu
  autoload -U +X bashcompinit && bashcompinit
  complete -o nospace -C "${BREW_PREFIX}/bin/tofu" tofu
  tofu "$@"
}

function terragrunt() {
  unset -f terragrunt
  autoload -U +X bashcompinit && bashcompinit
  complete -o nospace -C "${BREW_PREFIX}/bin/terragrunt" terragrunt
  terragrunt "$@"
}
