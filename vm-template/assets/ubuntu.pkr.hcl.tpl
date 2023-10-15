packer {
  required_plugins {
    name = {
      version = "~> 1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

locals {
  vm_ip = "192.168.2.98/24"
  vm_gateway = "192.168.2.1"
}

source "proxmox-clone" "ubuntu22" {
  clone_vm_id              = ${base_vm_id}
  sockets                  = 1
  vm_id                    = ${packer_vm_id}
  vm_name                  = "ubuntu22-packer"
  cores                    = 4
  insecure_skip_tls_verify = true
  memory                   = 8192
  network_adapters {
    bridge = "vmbr0"
    model  = "virtio"
  }

  ipconfig {
    ip = local.vm_ip
    gateway = local.vm_gateway
  }
 
  scsi_controller      = "virtio-scsi-pci"
  node                 = "${proxmox_node}"
  os                   = "${os_type}"
  proxmox_url          = "${proxmox_api_endpoint}api2/json"
  username             = "${proxmox_api_user}"
  token                = "${proxmox_api_token}"
  template_description = "image made from cloud-init ubuntu22 image"
  template_name        = "ubuntu22-latest"
  ssh_username         = "${guest_user}"
  ssh_host             = split("/", local.vm_ip)[0]
  ssh_private_key_file = "${ssh_key_path}"
}

build {
  sources = ["source.proxmox-clone.ubuntu22"]

  provisioner "shell"  {
    inline = [
      "cloud-init status --wait",
      "apt update",
      "apt -y upgrade",
      "apt-get autoremove -y",
      "apt install -y qemu-guest-agent git htop",
      "systemctl start qemu-guest-agent",
      "sleep 5"
    ]
  }
}
