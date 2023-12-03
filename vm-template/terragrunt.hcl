include "root" {
  path = find_in_parent_folders()
}


locals {
  common_vars = read_terragrunt_config("${get_parent_terragrunt_dir()}/shared/vars.hcl")
  secret_vars = yamldecode(sops_decrypt_file("${get_parent_terragrunt_dir()}/shared/secrets.yaml"))
}

inputs = merge(
  local.common_vars.inputs, 
  local.secret_vars,
  {}
)
