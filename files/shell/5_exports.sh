if which pass >/dev/null; then

    # Proxmox
    #PM_USER=$(pass hideOut/Terraform/Proxmox/user)
    #PM_PASS=$(pass hideOut/Terraform/Proxmox/pass)

    # Terraform
    export TF_TOKEN_app_terraform_io=$(pass hideOut/Terraform/app_terraform_io)
    export TF_VAR_proxmox_api_token_id=$(pass hideOut/Terraform/Proxmox/token_id)
    export TF_VAR_proxmox_api_token_secret=$(pass hideOut/Terraform/Proxmox/token_secret)

fi
