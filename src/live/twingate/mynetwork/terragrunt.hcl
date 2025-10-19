# Terragrunt configuration for Twingate network
terraform {
  source = "git::https://github.com/example/twingate-terraform-module.git?ref=v1.0.0"
}

# Include common configurations
include "root" {
  path = find_in_parent_folders()
}

# Twingate-specific inputs
inputs = {
  network_name = "mynetwork"
}
