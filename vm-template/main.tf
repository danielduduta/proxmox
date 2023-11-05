locals {
  base_vm_id   = 1001
  packer_vm_id = 101
  os_type      = "l26"
  datastore_id = "local"
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

output "private_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}

output "public_key" {
  value     = tls_private_key.ssh_key.public_key_openssh
  sensitive = true
}

resource "random_password" "password" {
  length  = 16
  special = false
}

resource "proxmox_virtual_environment_file" "ubuntu22_cloud_image" {
  content_type = "iso"
  datastore_id = local.datastore_id
  node_name    = var.proxmox_node
  source_file {
    path = var.ubuntu_remote_iso
  }
}

resource "proxmox_virtual_environment_vm" "ubuntu_vm_template" {
  name        = "ubuntu22-template"
  description = "Ubuntu22 Managed by Terraform"
  tags        = ["terraform", "ubuntu", "22"]

  node_name = var.proxmox_node
  vm_id     = local.base_vm_id

  agent {
    enabled = true
  }

  cpu {
    sockets = 1
    cores   = 1
    type    = "host"
    flags   = []
  }

  memory {
    dedicated = 4096
  }

  disk {
    datastore_id = local.datastore_id
    file_id      = proxmox_virtual_environment_file.ubuntu22_cloud_image.id
    interface    = "scsi0"
    size         = 10
  }

  initialization {
    datastore_id = local.datastore_id
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    user_account {
      username = var.guest_user
      password = random_password.password.result
      keys     = [trimspace(tls_private_key.ssh_key.public_key_openssh)]
    }
  }

  network_device {
    bridge = "vmbr0"
  }

  operating_system {
    type = local.os_type
  }

  on_boot       = false
  started       = false
  template      = true
  tablet_device = false
}

resource "local_file" "packer_ssh_key" {
  filename        = "${path.module}/pack/ssh.key"
  file_permission = "0600"
  content         = trimspace(tls_private_key.ssh_key.private_key_pem)

  depends_on = [
    proxmox_virtual_environment_file.ubuntu22_cloud_image
  ]
}

resource "local_file" "packer_ubuntu_template" {
  filename = "${path.module}/pack/ubuntu.pkr.hcl"
  content = templatefile("${path.module}/assets/ubuntu.pkr.hcl.tpl",
    {
      ssh_key_path         = "${abspath(path.module)}/${local_file.packer_ssh_key.filename}",
      proxmox_node         = var.proxmox_node,
      proxmox_api_endpoint = var.proxmox_api_endpoint,
      proxmox_api_user     = var.proxmox_api_user,
      proxmox_api_token    = split("=", var.proxmox_api_token)[1],
      base_vm_id           = local.base_vm_id,
      guest_user           = var.guest_user,
      packer_vm_id         = local.packer_vm_id,
      os_type              = local.os_type
    }
  )

  depends_on = [
    local_file.packer_ssh_key
  ]
}

resource "null_resource" "packer_build" {

  provisioner "local-exec" {
    working_dir = "${path.module}/pack"
    command     = "packer init . && packer build ."
  }

  provisioner "local-exec" {
    command = "rm -f pack/*"
  }

  depends_on = [
    local_file.packer_ubuntu_template
  ]
}
