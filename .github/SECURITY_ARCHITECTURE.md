# Security Workflow Architecture

## Overview

This document describes the comprehensive security automation implemented for this Terragrunt/Terraform infrastructure project.

## Workflow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    Security Workflow Triggers                    │
├─────────────────────────────────────────────────────────────────┤
│  • Pull Requests to main/develop                                │
│  • Push to main/develop                                          │
│  • Daily Schedule (2 AM UTC)                                     │
│  • Manual Dispatch                                               │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                   Parallel Security Scanning                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌────────────────────┐  ┌────────────────────┐                │
│  │  Terraform Checks  │  │   tfsec Scanner    │                │
│  │  • Format Check    │  │  • Security Issues │                │
│  │  • Init            │  │  • SARIF Output    │                │
│  │  • Validate        │  └────────────────────┘                │
│  └────────────────────┘                                         │
│                                                                   │
│  ┌────────────────────┐  ┌────────────────────┐                │
│  │ Checkov Scanner    │  │  Secret Scanning   │                │
│  │  • IaC Policies    │  │  • Gitleaks        │                │
│  │  • Compliance      │  │  • Credential Scan │                │
│  │  • SARIF Output    │  └────────────────────┘                │
│  └────────────────────┘                                         │
│                                                                   │
│  ┌────────────────────┐  ┌────────────────────┐                │
│  │  Semgrep SAST      │  │  Trivy Vuln Scan   │                │
│  │  • Code Analysis   │  │  • Config Scan     │                │
│  │  • Security Rules  │  │  • SARIF Output    │                │
│  └────────────────────┘  └────────────────────┘                │
│                                                                   │
│  ┌────────────────────┐                                         │
│  │ Terragrunt Check   │                                         │
│  │  • HCL Format      │                                         │
│  │  • Validation      │                                         │
│  └────────────────────┘                                         │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Results Aggregation                           │
├─────────────────────────────────────────────────────────────────┤
│  • Upload SARIF to GitHub Security                              │
│  • Generate Security Summary                                     │
│  • Update PR with Status Checks                                  │
│  • Notify on Failures                                            │
└─────────────────────────────────────────────────────────────────┘
```

## Security Layers

### Layer 1: Infrastructure as Code Security
- **tfsec**: Scans Terraform for security misconfigurations
- **Checkov**: Policy-as-code scanning with 1000+ built-in policies
- Detects: Unencrypted storage, public access, insecure networking, etc.

### Layer 2: Secret Detection
- **Gitleaks**: Detects hardcoded secrets, API keys, credentials
- Scans: Code, commit history, configuration files
- Prevents: Credential leaks, security breaches

### Layer 3: Static Application Security Testing (SAST)
- **Semgrep**: Scans for code-level security issues
- Rules: Terraform-specific, general security, secrets detection
- Detects: Insecure coding patterns, vulnerabilities

### Layer 4: Vulnerability Management
- **Trivy**: Scans for known vulnerabilities in dependencies
- Coverage: Configuration files, third-party modules
- Database: CVE, GitHub Security Advisories

### Layer 5: Configuration Validation
- **Terraform Validate**: Ensures syntax correctness
- **Terraform Format**: Enforces code style
- **Terragrunt Validation**: Validates HCL configurations

## Automation Features

### Continuous Security
```
Development Flow:
┌──────────────┐
│ Code Change  │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Create PR    │────────┐
└──────────────┘        │
                        ▼
                ┌───────────────┐
                │ Security Scan │
                │   Triggered   │
                └───────┬───────┘
                        │
                        ▼
                ┌───────────────┐
                │ All Checks    │
                │   Pass?       │
                └───────┬───────┘
                        │
            ┌───────────┼───────────┐
            │                       │
            ▼                       ▼
        ┌───────┐               ┌───────┐
        │  YES  │               │  NO   │
        └───┬───┘               └───┬───┘
            │                       │
            ▼                       ▼
    ┌──────────────┐       ┌──────────────┐
    │ Ready to     │       │ Fix Issues   │
    │ Merge        │       │ & Re-scan    │
    └──────────────┘       └──────────────┘
```

### Scheduled Security Audits
- Daily automated scans at 2 AM UTC
- Catches newly discovered vulnerabilities
- No manual intervention required
- Results in GitHub Security tab

### Dependency Updates
- Dependabot monitors GitHub Actions
- Dependabot monitors Terraform modules
- Automated PR creation for updates
- Security patches applied automatically

## Results Integration

### GitHub Security Tab
All security findings are uploaded to GitHub's Security tab using SARIF format:
- **Code Scanning Alerts**: tfsec, Checkov, Trivy findings
- **Secret Scanning**: Gitleaks results
- **Centralized View**: All security issues in one place
- **Tracking**: Monitor remediation progress

### Pull Request Status Checks
- Security scans must pass before merge
- Status badges show scan results
- Detailed logs available per job
- Summary posted to PR

## Local Development

### Pre-commit Hooks
Developers can run security checks locally before pushing:

```bash
# Install
pip install pre-commit
pre-commit install

# Run
pre-commit run --all-files
```

Benefits:
- Catch issues before CI/CD
- Faster feedback loop
- Reduced CI/CD usage
- Better code quality

## Security Policy

### Branch Protection
Recommended settings:
- Require PR reviews
- Require status checks (security scans)
- Require up-to-date branches
- Require signed commits

### Code Ownership
- CODEOWNERS file enforces reviews
- Security-critical files require additional approval
- Infrastructure changes reviewed by team leads

### Secrets Management
- `.gitignore` prevents committing sensitive files
- Gitleaks scans catch accidental commits
- Security policy documents best practices

## Compliance

This setup helps meet compliance requirements:
- **CIS Benchmarks**: Infrastructure security standards
- **OWASP**: Application security guidelines
- **Cloud Security**: AWS/Azure/GCP best practices
- **SOC 2**: Security controls and monitoring
- **GDPR/HIPAA**: Data protection requirements

## Monitoring & Alerts

### Security Findings
- GitHub Security Advisories
- Email notifications for critical issues
- Integration with SIEM (if configured)

### Metrics
- Scan duration and performance
- Issue trends over time
- Remediation time tracking
- Coverage statistics

## Continuous Improvement

### Regular Updates
- Security tools updated via Dependabot
- New security rules added regularly
- Policy refinements based on findings

### Feedback Loop
```
Scan → Find Issues → Fix → Scan Again → Learn → Improve Policies
```

## Getting Started

1. **Enable GitHub Security Features**
   - Go to Settings → Security → Enable security features
   - Enable Dependabot alerts and updates
   - Review security advisories

2. **Configure Branch Protection**
   - Require status checks to pass
   - Add security scan checks as required

3. **Review Security Policy**
   - Read SECURITY.md
   - Understand reporting procedures

4. **Run First Scan**
   - Trigger workflow manually or create a PR
   - Review findings in Security tab
   - Address critical/high severity issues

5. **Set Up Local Hooks** (Optional)
   - Install pre-commit
   - Run security checks before commits

## Support

For questions or issues:
- Review [SECURITY.md](../SECURITY.md)
- Check workflow logs
- Open an issue with `security` label
- Contact repository maintainers
