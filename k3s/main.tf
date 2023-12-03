locals {
  datastore_id = "nfs"
  subnet = "192.168.2.0/24"
  cp_nodes = { 
    for index in range(0, var.cp_nodes):
      index => "cp-${index}"
  }
  worker_nodes = {
    for index in range(0, var.worker_nodes):
      index => "worker-${index}"
  }
}

resource "proxmox_virtual_environment_file" "k3s_cloud_init" {
  content_type = "snippets"
  datastore_id = var.vm_datastore_id
  node_name    = var.proxmox_node

  source_raw {
    data = templatefile("./assets/user-data",
      {
        ssh_key = var.ssh_public_key
      }
    )
    file_name = "k3s.cloud-config.yaml"
  }
}


resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  for_each = local.cp_nodes
  name        = "${each.value}"
  description = "CP node ${each.key}"
  tags        = ["terraform", "ubuntu", "cp"]

  clone {
    vm_id        = var.vm_template_id
    datastore_id = var.vm_datastore_id
  }

  node_name = var.proxmox_node
  vm_id     = 1100 + each.key

  agent {
    enabled = true
  }

  cpu {
    sockets = 1
    cores   = 4
    type    = "host"
    flags   = []
  }

  memory {
    dedicated = 8192
  }

  disk {
    datastore_id = local.datastore_id
    interface    = "scsi0"
    size         = 50
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  initialization {
    datastore_id = local.datastore_id
    ip_config {
      ipv4 {
        address = "${cidrhost(local.subnet, 20 + each.key)}/24"
        gateway = "192.168.2.1"
      }
    }
    user_data_file_id = proxmox_virtual_environment_file.k3s_cloud_init.id
  }

  started       = true
  on_boot       = true
  tablet_device = false
}
