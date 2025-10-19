# Terragrunt configuration for VPC in dev environment
terraform {
  source = "../../../../../../services/vpc"
}

# Include common configurations
include "root" {
  path = find_in_parent_folders()
}

# Include region-specific configurations
include "region" {
  path = find_in_parent_folders("region.hcl")
}

# Include project-specific configurations
include "project" {
  path = find_in_parent_folders("project.hcl")
}

# VPC-specific inputs
inputs = {
  environment = "dev"
  region      = "us-east-1"
}
