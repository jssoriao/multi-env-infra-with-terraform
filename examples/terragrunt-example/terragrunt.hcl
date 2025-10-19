# Example Terragrunt configuration
# This demonstrates a basic Terragrunt setup

terraform {
  source = "../basic"
}

# Include root terragrunt configuration if it exists
# include "root" {
#   path = find_in_parent_folders()
# }

inputs = {
  aws_region  = "us-east-1"
  environment = "dev"
}

# Configure remote state (example - commented out)
# remote_state {
#   backend = "s3"
#   config = {
#     bucket         = "my-terraform-state"
#     key            = "${path_relative_to_include()}/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "terraform-locks"
#   }
# }
