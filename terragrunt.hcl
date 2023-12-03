remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    profile = "duduta"
    bucket = "duduta-terraform-local-development"
    key = "${path_relative_to_include()}/terraform.tfstate"
    region         = "eu-west-1"
    encrypt = true
    skip_bucket_root_access  = true
  }
}

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "proxmox" {
  endpoint  = var.proxmox_api_endpoint
  api_token = var.proxmox_api_token
  insecure  = true
  ssh {
    username = var.proxmox_user
    password = var.proxmox_pass
  }
}
EOF
}

generate "required_provider" {
  path = "required_providers.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.34.0"
    }
  }
}
EOF
}
