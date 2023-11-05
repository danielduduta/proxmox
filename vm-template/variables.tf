variable "proxmox_node" {
  type        = string
  description = "proxmox node name"
}

variable "proxmox_user" {
  type        = string
  description = "user for proxmox"
}

variable "proxmox_pass" {
  type        = string
  sensitive   = true
  description = "root password for proxmox"
}

variable "proxmox_api_endpoint" {
  type        = string
  description = "proxmox node name"
}

variable "proxmox_api_user" {
  type        = string
  description = "proxmox node name"
}

variable "proxmox_api_token" {
  type        = string
  sensitive   = true
  description = "proxmox api token"
}

variable "guest_user" {
  type        = string
  description = "vm user"
}

variable "ubuntu_remote_iso" {
  type        = string
  description = "ubuntu iso"
}
