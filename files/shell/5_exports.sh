export KUBE_CONFIG_PATH="${HOME}/.kube/config"
export SOPS_AGE_KEY_FILE="${HOME}/.config/sops/age/keys.txt"

# --- Secrets Management (lazy loaded via `pass`) ---
# Define secrets as "ENV_VAR:pass/path" pairs
_SECRET_ENTRIES=(
  "PM_API_TOKEN_ID:hideOut/Terraform/Proxmox/token_id"
  "PM_API_TOKEN_SECRET:hideOut/Terraform/Proxmox/token_secret"
  "MINIO_USER:hideOut/OpenMediaVault/s3/user"
  "MINIO_PASSWORD:hideOut/OpenMediaVault/s3/pass"
  "AWS_ACCESS_KEY_ID:hideOut/OpenMediaVault/s3/access_key"
  "AWS_SECRET_ACCESS_KEY:hideOut/OpenMediaVault/s3/secret_key"
  "VAULT_TOKEN:hideOut/Vault/root_token"
  "VAULT_UNSEAL_KEY:hideOut/Vault/unseal_key"
  "VAULT_ADDR:hideOut/Vault/addr"
  "CLOUDFLARE_API_TOKEN:hideOut/CloudFlare/api_token"
  "NPM_TOKEN:hideOut/NPM/youHide/token"
  "NPM_TOKEN_YOUHIDE:hideOut/NPM/youHide/token"
  "NPM_TOKEN_NPM:hideOut/NPM/token"
)

function load_secrets() {
  if [[ -n "$_SECRETS_LOADED" ]]; then
    echo "Secrets already loaded."
    return 0
  fi

  if ! command -v pass &>/dev/null; then
    echo "pass not found, skipping secrets."
    return 1
  fi

  echo "Loading secrets from pass..."
  for entry in "${_SECRET_ENTRIES[@]}"; do
    local _var="${entry%%:*}"
    local _pass_path="${entry#*:}"
    export "$_var"="$(pass "$_pass_path")"
  done

  export _SECRETS_LOADED=1
  echo "Secrets loaded (${#_SECRET_ENTRIES[@]} entries)."
}

function unload_secrets() {
  for entry in "${_SECRET_ENTRIES[@]}"; do
    unset "${entry%%:*}"
  done
  unset _SECRETS_LOADED
  echo "Secrets unloaded."
}

function list_secrets() {
  echo "Configured secrets:"
  for entry in "${_SECRET_ENTRIES[@]}"; do
    local var="${entry%%:*}"
    if [[ -n "${(P)var}" ]]; then
      echo "  ${GREEN}✔${NOCOLOR} $var"
    else
      echo "  ${RED}✘${NOCOLOR} $var (not loaded)"
    fi
  done
}

# --- Lazy load NVM ---
if [[ -d "${BREW_PREFIX:-}/opt/nvm" ]]; then
  export NVM_DIR="$HOME/.nvm"

  _load_nvm() {
    unset -f nvm node npm npx pnpm _load_nvm
    [ -s "${BREW_PREFIX}/opt/nvm/nvm.sh" ] && \. "${BREW_PREFIX}/opt/nvm/nvm.sh"
    [ -s "${BREW_PREFIX}/opt/nvm/etc/bash_completion.d/nvm" ] && \. "${BREW_PREFIX}/opt/nvm/etc/bash_completion.d/nvm"
  }

  nvm()  { _load_nvm; nvm  "$@"; }
  node() { _load_nvm; node "$@"; }
  npm()  { _load_nvm; npm  "$@"; }
  npx()  { _load_nvm; npx  "$@"; }
  pnpm() { _load_nvm; pnpm "$@"; }
fi
