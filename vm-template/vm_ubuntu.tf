resource "proxmox_virtual_environment_file" "ubuntu22_cloud_init" {
  content_type = "snippets"
  datastore_id = local.datastore_id
  node_name    = var.proxmox_node
  
  source_raw {
    data  = templatefile("./assets/user-data", { ssh_key = tls_private_key.ssh_key.public_key_openssh })
    file_name = "ubuntu22.cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  name        = "ubuntu22-01"
  description = "Ubuntu22 Managed by Terraform"
  tags        = ["terraform", "ubuntu", "22"]

  clone {
    vm_id        = local.packer_vm_id
    datastore_id = local.datastore_id
  }

  node_name = var.proxmox_node
  vm_id     = 1002

  agent {
    enabled = true
  }

  cpu {
    sockets = 1
    cores = 1
    type = "host"
    flags = []
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

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  initialization {
    datastore_id = local.datastore_id
    ip_config {
      ipv4 {
        address = "192.168.2.90/24"
        gateway = "192.168.2.1"
      }
    }
    user_data_file_id = proxmox_virtual_environment_file.ubuntu22_cloud_init.id
  }

  started       = true
  on_boot       = true
  tablet_device = false
}
