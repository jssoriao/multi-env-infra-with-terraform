## Description
<!-- Provide a brief description of the changes in this PR -->

## Type of Change
<!-- Mark the relevant option with an "x" -->
- [ ] New infrastructure resource
- [ ] Infrastructure update/modification
- [ ] Configuration change
- [ ] Security fix
- [ ] Bug fix
- [ ] Documentation update
- [ ] CI/CD workflow change

## Security Checklist
<!-- Ensure all items are addressed before requesting review -->
- [ ] No secrets or sensitive data are committed
- [ ] All security scans have passed (tfsec, Checkov, Gitleaks, etc.)
- [ ] Infrastructure follows least privilege principle
- [ ] Network security groups/firewall rules are properly configured
- [ ] Encryption is enabled where applicable
- [ ] Access controls are properly configured
- [ ] No hardcoded credentials or API keys

## Testing
<!-- Describe how you tested these changes -->
- [ ] `terraform validate` passed
- [ ] `terraform plan` reviewed
- [ ] `terragrunt validate` passed (if applicable)
- [ ] All automated security scans passed
- [ ] Manual security review completed

## Infrastructure Impact
<!-- Describe the impact on existing infrastructure -->
- [ ] No impact on existing resources
- [ ] Updates existing resources (list them)
- [ ] Creates new resources (list them)
- [ ] Deletes resources (list them and justify)

## Documentation
<!-- Ensure documentation is updated -->
- [ ] README updated (if needed)
- [ ] Architecture diagrams updated (if needed)
- [ ] Security documentation updated (if needed)
- [ ] Comments added to complex configurations

## Additional Notes
<!-- Add any additional context, screenshots, or information -->

## Reviewer Notes
<!-- Information for reviewers -->
- Security considerations have been addressed
- All CI/CD checks must pass before merge
- Follow-up issues created (if any): 

---
**By submitting this PR, I confirm that:**
- I have followed the security guidelines
- I have tested these changes
- I have not committed any secrets or sensitive data
