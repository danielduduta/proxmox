# proxmox
terraform proxmox state that creates golden images via packer/cloud-init

cd vm-template/
TF_VAR_proxmox_pass="*****" TF_VAR_proxmox_api_token="****" terraform apply

