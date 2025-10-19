# Project-level configuration for network resources
locals {
  project_name = "network"
  project_tags = {
    Project     = "network"
    ManagedBy   = "terragrunt"
  }
}
