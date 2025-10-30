# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- OIDC authentication examples for AWS and Azure
- GCP support
- Terraform Cloud integration
- Policy-as-code examples (OPA, Sentinel)

## [1.0.0] - 2024-10-30

### Added
- **Multi-cloud support** for AWS and Azure
- **Custom Terraform modules**:
  - AWS compute module (VPC, EC2, Security Groups, EIP)
  - Azure compute module (VNet, VM, NSG, Public IP)
- **Environment separation**:
  - Development environments (aws-dev, azure-dev)
  - Production environments (aws-prod, azure-prod)
- **GitHub Actions workflows**:
  - Automated `terraform plan` on pull requests
  - Automated `terraform apply` on merge to main
  - Production approval gates
  - Separate workflows for AWS and Azure
- **Remote state management**:
  - AWS: S3 + DynamoDB + KMS encryption
  - Azure: Storage Account with built-in locking
- **Backend setup scripts**:
  - `setup-aws-backend.sh` - Automated AWS backend creation
  - `setup-azure-backend.sh` - Automated Azure backend creation
- **Comprehensive documentation**:
  - SETUP.md - Complete setup guide with VS Code integration
  - ARCHITECTURE.md - System design and remote state explanation
  - PHASE_EXPANSION.md - Migration guide for OIDC and Vault
  - QUICK_REFERENCE.md - Command cheat sheet
- **Enterprise-grade files**:
  - CONTRIBUTING.md - Contribution guidelines
  - CODE_OF_CONDUCT.md - Community standards
  - SECURITY.md - Security policy and best practices
  - LICENSE - MIT License
- **Project management**:
  - GitHub issue templates
  - Pull request template
  - CODEOWNERS file
  - Professional README with badges

### Security
- State encryption at rest (KMS, Azure SSE)
- State locking to prevent concurrent modifications
- Encrypted credentials via GitHub Secrets
- Least-privilege IAM policies
- Audit logging capabilities

### Documentation
- Step-by-step setup instructions
- VS Code and GitHub integration guide
- Detailed explanation of two-backend architecture
- Security best practices
- Troubleshooting guides
- Migration paths to advanced configurations

## [0.1.0] - Initial Development

### Added
- Initial project structure
- Basic Terraform modules
- GitHub Actions workflow templates

---

## Version History

### Release Naming Convention
- **Major (X.0.0)**: Breaking changes, major new features
- **Minor (1.X.0)**: New features, backwards compatible
- **Patch (1.0.X)**: Bug fixes, documentation updates

### Upgrade Guides

#### Upgrading to 1.0.0
This is the initial release. Follow the setup guide in `docs/SETUP.md`.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for information about contributing to this project.

## Links

- [GitHub Repository](https://github.com/iracic82/terraform-github-actions-starter)
- [Documentation](docs/)
- [Issue Tracker](https://github.com/iracic82/terraform-github-actions-starter/issues)
- [Discussions](https://github.com/iracic82/terraform-github-actions-starter/discussions)
