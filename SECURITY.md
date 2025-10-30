# Security Policy

## Supported Versions

We release patches for security vulnerabilities. Currently supported versions:

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

Instead, please report them via email to: **[security@example.com]** (Update with your email)

You should receive a response within 48 hours. If for some reason you do not, please follow up via email to ensure we received your original message.

Please include the following information:

- Type of issue (e.g., buffer overflow, SQL injection, cross-site scripting, etc.)
- Full paths of source file(s) related to the manifestation of the issue
- The location of the affected source code (tag/branch/commit or direct URL)
- Any special configuration required to reproduce the issue
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the issue, including how an attacker might exploit it

## Security Best Practices

### Credentials Management

**DO:**
- ✅ Use GitHub Secrets for sensitive data
- ✅ Rotate credentials regularly
- ✅ Use OIDC when possible (see Phase 2)
- ✅ Use least-privilege IAM policies
- ✅ Enable MFA on cloud accounts

**DON'T:**
- ❌ Commit credentials to Git
- ❌ Use long-lived credentials in production
- ❌ Share credentials across teams
- ❌ Use root/admin accounts for automation

### Terraform State Security

**DO:**
- ✅ Enable encryption at rest (S3 SSE-KMS, Azure Storage)
- ✅ Enable versioning on state storage
- ✅ Use state locking (DynamoDB, Azure Blob Lease)
- ✅ Restrict access with IAM/RBAC
- ✅ Enable audit logging (CloudTrail, Azure Monitor)

**DON'T:**
- ❌ Store state files locally
- ❌ Use public S3 buckets
- ❌ Disable encryption
- ❌ Grant public access to state

### GitHub Actions Security

**DO:**
- ✅ Use pinned action versions (`@v4`)
- ✅ Review action permissions
- ✅ Use GitHub Environments for approvals
- ✅ Limit workflow permissions (`id-token: write`, `contents: read`)
- ✅ Use CODEOWNERS for sensitive files

**DON'T:**
- ❌ Use `actions/checkout@main` (unpinned)
- ❌ Grant excessive permissions
- ❌ Skip production approvals
- ❌ Log sensitive information

### Cloud Infrastructure Security

**AWS:**
- Enable VPC Flow Logs
- Use Security Groups (not NACLs) as primary firewall
- Enable CloudTrail in all regions
- Use AWS Config for compliance
- Restrict SSH access (use SSM Session Manager instead)

**Azure:**
- Enable Network Security Groups (NSGs)
- Use Azure Security Center
- Enable Azure Monitor
- Use Azure Bastion for secure access
- Implement Azure Policy

### Dependency Security

- Keep Terraform provider versions up to date
- Scan for vulnerabilities (`tfsec`, `checkov`)
- Review module sources before use
- Pin module versions in production

## Security Scanning

### Recommended Tools

1. **tfsec** - Static analysis for Terraform
   ```bash
   tfsec .
   ```

2. **Checkov** - Policy-as-code scanner
   ```bash
   checkov -d .
   ```

3. **Terrascan** - Compliance scanning
   ```bash
   terrascan scan -t terraform
   ```

4. **Trivy** - Vulnerability scanner
   ```bash
   trivy config .
   ```

### GitHub Actions Integration

Add security scanning to your workflows:

```yaml
- name: Security Scan
  uses: aquasecurity/trivy-action@master
  with:
    scan-type: 'config'
    scan-ref: '.'
```

## Incident Response

If you discover a security vulnerability:

1. **Assess the impact** - Determine severity and affected systems
2. **Contain the threat** - Revoke compromised credentials immediately
3. **Report the incident** - Contact security team
4. **Remediate** - Apply fixes and patches
5. **Document** - Record incident details and lessons learned
6. **Communicate** - Inform affected parties if necessary

## Security Updates

We will:
- Publish security advisories for confirmed vulnerabilities
- Release patches as quickly as possible
- Credit reporters (unless anonymity is requested)
- Maintain a security changelog

## Compliance

This template supports compliance with:
- **SOC 2** - Audit logging, access controls
- **ISO 27001** - Security management
- **NIST Cybersecurity Framework** - Risk management
- **CIS Benchmarks** - Cloud provider best practices

## Contact

For security concerns, contact:
- **Email**: [security@example.com]
- **PGP Key**: [Link to PGP key]

---

**Security is everyone's responsibility. Thank you for helping keep this project secure!**
