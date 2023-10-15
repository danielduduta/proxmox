provider "proxmox" {
  endpoint = var.proxmox_api_endpoint
  api_token = var.proxmox_api_token
  insecure = true
  ssh {
    username = var.proxmox_user
    password = var.proxmox_pass
  }
}
