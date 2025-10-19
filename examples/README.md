# Examples

This directory contains example Terraform and Terragrunt configurations to demonstrate the security workflow.

## Basic Example

The `basic/` directory contains a simple AWS S3 bucket configuration that follows security best practices:

- Server-side encryption enabled
- Versioning enabled
- Public access blocked
- Proper tagging

### Usage

```bash
cd examples/basic
terraform init
terraform plan
terraform apply
```

## Terragrunt Example

The `terragrunt-example/` directory demonstrates a basic Terragrunt configuration that references the basic example.

### Usage

```bash
cd examples/terragrunt-example
terragrunt init
terragrunt plan
terragrunt apply
```

## Security Scanning

All examples are automatically scanned by the security workflow. You can also run security checks locally:

### tfsec
```bash
tfsec examples/basic
```

### Checkov
```bash
checkov -d examples/basic
```

### Terraform Validate
```bash
cd examples/basic
terraform init -backend=false
terraform validate
terraform fmt -check
```

## Notes

- These are examples for demonstration purposes
- Do not use in production without proper review and customization
- Always review security scan results
- Configure remote state management for production use
