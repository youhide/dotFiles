if which pass >/dev/null; then

    #PM_USER=$(pass hideOut/Terraform/Proxmox/user)
    #PM_PASS=$(pass hideOut/Terraform/Proxmox/pass)

    export PM_API_TOKEN_ID=$(pass hideOut/Terraform/Proxmox/token_id)
    export PM_API_TOKEN_SECRET=$(pass hideOut/Terraform/Proxmox/token_secret)

    export MINIO_USER=$(pass hideOut/OpenMediaVault/s3/user)
    export MINIO_PASSWORD=$(pass hideOut/OpenMediaVault/s3/pass)   
     
    export AWS_ACCESS_KEY_ID=$(pass hideOut/OpenMediaVault/s3/access_key)
    export AWS_SECRET_ACCESS_KEY=$(pass hideOut/OpenMediaVault/s3/secret_key)

    export VAULT_TOKEN=$(pass hideOut/Vault/root_token)
    export VAULT_UNSEAL_KEY=$(pass show hideOut/Vault/unseal_key)
    export VAULT_ADDR=$(pass show hideOut/Vault/addr)

    export AUTHENTIK_URL=$(pass TKA/Authentik/url)
    export AUTHENTIK_TOKEN=$(pass TKA/Authentik/token)

fi
