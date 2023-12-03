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

variable "cp_nodes" {
  type = number
  description = "number of k8s control plane nodes"
  default = 3
}

variable "worker_nodes" {
  type = number
  description = "number of k8s worker nodes"
  default = 3
}


variable "vm_template_id" {
  type = number
}

variable "vm_datastore_id" {
  type = string
}

variable "ssh_public_key" {
  type = string
}