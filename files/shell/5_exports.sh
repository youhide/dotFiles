if which pass >/dev/null; then

    # Proxmox
    #PM_USER=$(pass hideOut/Terraform/Proxmox/user)
    #PM_PASS=$(pass hideOut/Terraform/Proxmox/pass)

    # Terraform
    export PM_API_TOKEN_ID=$(pass hideOut/Terraform/Proxmox/token_id)
    export PM_API_TOKEN_SECRET=$(pass hideOut/Terraform/Proxmox/token_secret)

    export MINIO_USER=$(pass hideOut/OpenMediaVault/s3/user)
    export MINIO_PASSWORD=$(pass hideOut/OpenMediaVault/s3/pass)   
     
    export TF_VAR_s3_access_key=$(pass hideOut/OpenMediaVault/s3/access_key)
    export TF_VAR_s3_secret_key=$(pass hideOut/OpenMediaVault/s3/secret_key)

fi
