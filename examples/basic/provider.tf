# Example provider configuration
# Note: In production, configure backend for state management

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "multi-env-infra"
      ManagedBy   = "Terraform"
      Environment = var.environment
    }
  }
}

provider "random" {
  # Random provider for generating unique identifiers
}
