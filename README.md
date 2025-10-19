# multi-env-infra-with-terraform

Multi-environment infrastructure management with Terraform and Terragrunt, featuring comprehensive security automation.

## 🔒 Security Features

This repository implements enterprise-grade security automation:

### Automated Security Scanning

- **tfsec**: Terraform static analysis security scanner
- **Checkov**: Infrastructure security and compliance scanning
- **Gitleaks**: Secret detection and prevention
- **Semgrep**: SAST (Static Application Security Testing)
- **Trivy**: Vulnerability scanning for IaC configurations
- **Dependabot**: Automated dependency updates

### Security Workflow

The security workflow runs:
- ✅ On every pull request
- ✅ On push to main/develop branches
- ✅ Daily scheduled scans (2 AM UTC)
- ✅ On-demand via workflow dispatch

### Security Results

All security scan results are:
- Uploaded to GitHub Security tab (SARIF format)
- Displayed in pull request checks
- Summarized in workflow run summaries

## 🚀 Getting Started

### Prerequisites

- Terraform >= 1.0
- Terragrunt >= 0.45
- (Optional) pre-commit for local security checks

### Local Development with Security Checks

1. Install pre-commit hooks (optional but recommended):
   ```bash
   pip install pre-commit
   pre-commit install
   ```

2. Run security checks locally:
   ```bash
   pre-commit run --all-files
   ```

### Project Structure

```
.
├── .github/
│   ├── workflows/
│   │   └── security.yml          # Main security workflow
│   ├── dependabot.yml             # Dependency updates
│   ├── CODEOWNERS                 # Code review requirements
│   └── PULL_REQUEST_TEMPLATE.md   # PR security checklist
├── .pre-commit-config.yaml        # Local pre-commit hooks
├── .gitignore                     # Prevents committing secrets
├── SECURITY.md                    # Security policy
└── README.md                      # This file
```

## 📋 Security Checklist

Before committing code, ensure:

- [ ] No hardcoded secrets or credentials
- [ ] All `.tfvars` files with sensitive data are in `.gitignore`
- [ ] Security groups follow least privilege principle
- [ ] Encryption is enabled where applicable
- [ ] All security scans pass locally (if using pre-commit)

## 🛡️ Security Policy

See [SECURITY.md](SECURITY.md) for:
- Vulnerability reporting procedures
- Supported versions
- Security measures and compliance
- Required GitHub secrets configuration

## 📝 Contributing

1. Create a feature branch
2. Make your changes following security best practices
3. Run local security checks (pre-commit)
4. Submit a pull request using the PR template
5. Ensure all security scans pass

## 📚 Additional Resources

- [Terraform Security Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [Terragrunt Documentation](https://terragrunt.gruntwork.io/docs/)
- [tfsec Documentation](https://aquasecurity.github.io/tfsec/)
- [Checkov Documentation](https://www.checkov.io/)

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Support

For security issues, please see [SECURITY.md](SECURITY.md).
For other questions, please open an issue.