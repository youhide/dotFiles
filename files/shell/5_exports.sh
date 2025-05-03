if which pass >/dev/null; then

    # Proxmox
    #PM_USER=$(pass hideOut/Terraform/Proxmox/user)
    #PM_PASS=$(pass hideOut/Terraform/Proxmox/pass)

    # Terraform
    export TF_VAR_proxmox_token_id=$(pass hideOut/Terraform/Proxmox/token_id)
    export TF_VAR_proxmox_token_secret=$(pass hideOut/Terraform/Proxmox/token_secret)
    export TF_VAR_s3_access_key=$(pass hideOut/OpenMediaVault/s3/access_key)
    export TF_VAR_s3_secret_key=$(pass hideOut/OpenMediaVault/s3/secret_key)

fi
