# Security Policy

## Reporting Security Vulnerabilities

If you discover a security vulnerability within this project, please send an email to the repository owner. All security vulnerabilities will be promptly addressed.

**Please do not report security vulnerabilities through public GitHub issues.**

## Supported Versions

We release patches for security vulnerabilities. Which versions are eligible for receiving such patches depend on the CVSS v3.0 Rating:

| Version | Supported          |
| ------- | ------------------ |
| Latest  | :white_check_mark: |
| Older   | :x:                |

## Security Measures

This repository implements the following security measures:

### Automated Security Scanning

- **tfsec**: Scans Terraform code for potential security issues
- **Checkov**: Policy-as-code security scanning for infrastructure
- **Gitleaks**: Detects hardcoded secrets and credentials
- **Semgrep**: Static analysis security testing (SAST)
- **Trivy**: Vulnerability scanning for dependencies and configurations

### Continuous Monitoring

- Security scans run on every pull request
- Daily scheduled scans to catch new vulnerabilities
- Dependabot for automated dependency updates
- GitHub Security Advisories monitoring

### Best Practices

1. **Never commit secrets**: Use environment variables or secret management systems
2. **Review security alerts**: Check GitHub Security tab regularly
3. **Keep dependencies updated**: Merge Dependabot PRs promptly
4. **Follow least privilege**: Grant minimal necessary permissions
5. **Validate configurations**: All Terraform/Terragrunt code is validated before merge

## Security Configuration

### Required Secrets

The following GitHub secrets may be needed for enhanced security features:

- `SEMGREP_APP_TOKEN` (optional): For Semgrep Pro features
- `GITLEAKS_LICENSE` (optional): For Gitleaks Pro features

### Branch Protection

We recommend enabling the following branch protection rules:

- Require pull request reviews before merging
- Require status checks to pass (security scans)
- Require branches to be up to date before merging
- Require signed commits
- Restrict who can push to main/develop branches

## Compliance

This project follows security best practices for infrastructure as code:

- CIS Benchmarks
- OWASP guidelines
- Cloud provider security best practices
- Terraform/Terragrunt security guidelines
