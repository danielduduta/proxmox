terraform {
  backend "s3" {
        profile = "duduta"
        bucket = "duduta-terraform-local-development"
        key = "proxmox/vm-templates"
        region = "eu-west-1"
  }
}
