include "root" {
  path = find_in_parent_folders()
}

dependency "vm" {
  config_path = "../vm-template"
}

locals {
  common_vars = read_terragrunt_config("${get_parent_terragrunt_dir()}/shared/vars.hcl")
  secret_vars = yamldecode(sops_decrypt_file("${get_parent_terragrunt_dir()}/shared/secrets.yaml"))
}

inputs = merge(
  local.common_vars.inputs,
  local.secret_vars,
  { 
    vm_template_id = dependency.vm.outputs.vm_template_id,
    vm_datastore_id = dependency.vm.outputs.datastore_id,
    ssh_public_key = dependency.vm.outputs.public_key
  }
)