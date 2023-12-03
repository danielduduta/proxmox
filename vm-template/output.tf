output "private_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}

output "public_key" {
  value     = tls_private_key.ssh_key.public_key_openssh
  sensitive = true
}

output "datastore_id" {
    value = local.datastore_id
} 

output "proxmox_node" {
  value = var.proxmox_node
}

output "vm_template_id" {
  value = local.packer_vm_id
}
