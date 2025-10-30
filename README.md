# Terraform GitHub Actions Starter Template

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Terraform](https://img.shields.io/badge/Terraform-1.6+-purple.svg)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Supported-orange.svg)](https://aws.amazon.com/)
[![Azure](https://img.shields.io/badge/Azure-Supported-0078D4.svg)](https://azure.microsoft.com/)
[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-Enabled-2088FF.svg)](https://github.com/features/actions)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

> **Enterprise-grade Infrastructure as Code template for multi-cloud deployments**

A production-ready, battle-tested template for managing infrastructure as code using Terraform and GitHub Actions. This template demonstrates enterprise best practices for multi-cloud deployments (AWS and Azure) with custom modules, environment separation, and automated CI/CD workflows.

---

## 📋 Table of Contents

- [Features](#-features)
- [Quick Start](#-quick-start)
- [Project Structure](#-project-structure)
- [Documentation](#-documentation)
- [Deployment Phases](#-deployment-phases)
- [Workflows](#-workflows)
- [Best Practices](#-best-practices)
- [Security](#-security)
- [Contributing](#-contributing)
- [License](#-license)

---

## ✨ Features

- **Multi-Cloud Support**: Deploy to both AWS and Azure
- **Custom Terraform Modules**: Reusable modules for VPC, EC2, VNet, VMs, Security Groups, and NSGs
- **Environment Separation**: Dedicated dev and prod environments with isolated state
- **GitHub Actions CI/CD**: Automated plan on PR, apply on merge with approval gates
- **Remote State Management**: S3 + DynamoDB for AWS, Azure Storage for Azure
- **Phase-Based Implementation**: Start simple with GitHub Secrets, expand to OIDC and Vault
- **PR Approval Workflow**: Automated planning on pull requests, manual approval for production

## 🚀 Quick Start

### Prerequisites

- GitHub repository with admin access
- AWS account with admin permissions
- Azure subscription with contributor access
- GitHub CLI (`gh`) installed (optional, for easier setup)

### 1. Clone This Template

```bash
# Use this repository as a template
gh repo create my-terraform-infrastructure --template YOUR_ORG/terraform-github-actions-starter --private --clone

# Or clone directly
git clone https://github.com/YOUR_ORG/terraform-github-actions-starter.git my-terraform-infrastructure
cd my-terraform-infrastructure
```

### 2. Setup Backend (Choose your cloud)

#### AWS Backend Setup
```bash
# Edit the script with your AWS account details
vim scripts/setup-aws-backend.sh

# Run the setup script
./scripts/setup-aws-backend.sh
```

#### Azure Backend Setup
```bash
# Edit the script with your Azure subscription details
vim scripts/setup-azure-backend.sh

# Run the setup script
./scripts/setup-azure-backend.sh
```

### 3. Configure GitHub Secrets (Phase 1)

**For AWS:**
```bash
# Set AWS credentials as GitHub secrets
gh secret set AWS_ACCESS_KEY_ID --body "YOUR_ACCESS_KEY"
gh secret set AWS_SECRET_ACCESS_KEY --body "YOUR_SECRET_KEY"
gh secret set AWS_REGION --body "us-east-1"
```

**For Azure:**
```bash
# Set Azure credentials as GitHub secrets
gh secret set AZURE_CLIENT_ID --body "YOUR_CLIENT_ID"
gh secret set AZURE_CLIENT_SECRET --body "YOUR_CLIENT_SECRET"
gh secret set AZURE_SUBSCRIPTION_ID --body "YOUR_SUBSCRIPTION_ID"
gh secret set AZURE_TENANT_ID --body "YOUR_TENANT_ID"
```

### 4. Customize Your Infrastructure

Edit the environment-specific configurations:
- `environments/aws-dev/main.tf` - Your AWS dev infrastructure
- `environments/aws-prod/main.tf` - Your AWS prod infrastructure
- `environments/azure-dev/main.tf` - Your Azure dev infrastructure
- `environments/azure-prod/main.tf` - Your Azure prod infrastructure

### 5. Test the Workflow

```bash
# Create a new branch
git checkout -b feature/initial-setup

# Make your changes and commit
git add .
git commit -m "Initial infrastructure setup"

# Push and create PR
git push origin feature/initial-setup
gh pr create --title "Initial infrastructure setup" --body "Setting up initial infrastructure"
```

The GitHub Actions workflow will automatically run `terraform plan` and post the results to your PR.

### 6. Deploy to Production

1. Review the plan in the PR comments
2. Merge the PR to `main` branch
3. Approve the production deployment in GitHub Actions
4. Monitor the apply process

## 📁 Project Structure

```
.
├── README.md                          # This file
├── docs/
│   ├── SETUP.md                       # Detailed setup guide
│   ├── ARCHITECTURE.md                # Architecture overview
│   └── PHASE_EXPANSION.md             # Guide for OIDC and Vault integration
├── .github/
│   └── workflows/
│       ├── terraform-aws-dev.yml      # AWS dev workflow (plan on PR)
│       ├── terraform-aws-prod.yml     # AWS prod workflow (apply on merge)
│       ├── terraform-aws-destroy.yml  # AWS destroy workflow (manual trigger)
│       ├── terraform-azure-dev.yml    # Azure dev workflow (plan on PR)
│       └── terraform-azure-prod.yml   # Azure prod workflow (apply on merge)
├── modules/
│   ├── aws/
│   │   ├── vpc/                       # Custom VPC module
│   │   ├── ec2/                       # Custom EC2 module
│   │   └── security-group/            # Custom Security Group module
│   └── azure/
│       ├── vnet/                      # Custom VNet module
│       ├── vm/                        # Custom VM module
│       └── nsg/                       # Custom NSG module
├── environments/
│   ├── aws-dev/                       # AWS dev environment
│   ├── aws-prod/                      # AWS prod environment
│   ├── azure-dev/                     # Azure dev environment
│   └── azure-prod/                    # Azure prod environment
└── scripts/
    ├── setup-aws-backend.sh           # AWS backend setup script
    └── setup-azure-backend.sh         # Azure backend setup script
```

## 🔄 Deployment Phases

### Phase 1: GitHub Secrets (Current)
- Use GitHub Secrets for cloud credentials
- S3/Azure Storage backend for state
- PR-based plan, merge-based apply
- Production approval gates

### Phase 2: OIDC Federation (Future)
- Remove static credentials
- Use GitHub OIDC with AWS IAM and Azure Entra ID
- Short-lived tokens for enhanced security

### Phase 3: Vault Integration (Future)
- Centralized secret management with HashiCorp Vault
- Dynamic credential generation
- Audit logging and secret rotation

See [docs/PHASE_EXPANSION.md](docs/PHASE_EXPANSION.md) for migration guides.

## 📚 Documentation

- [Detailed Setup Guide](docs/SETUP.md) - Step-by-step setup instructions
- [Architecture Overview](docs/ARCHITECTURE.md) - System design and components
- [Phase Expansion Guide](docs/PHASE_EXPANSION.md) - How to expand to OIDC and Vault

## ⚙️ Workflows Explained

### Development Workflow (PR-based)
1. Developer creates feature branch
2. Developer makes infrastructure changes
3. Developer creates PR to `main`
4. GitHub Actions runs `terraform plan`
5. Plan results posted as PR comment
6. Team reviews plan in PR
7. PR merged after approval

### Production Deployment Workflow
1. PR merged to `main`
2. GitHub Actions workflow triggered
3. Workflow waits for manual approval (production environment)
4. After approval, `terraform apply` executes
5. Infrastructure deployed to production

### Manual Workflow Triggers

Some workflows can be triggered manually using `workflow_dispatch`:

**Manually Deploy Production:**
```bash
gh workflow run "Terraform AWS Prod - Apply"
gh workflow run "Terraform Azure Prod - Apply"
```

**Destroy Infrastructure:**
```bash
# Destroy AWS infrastructure (requires typing "destroy" to confirm)
gh workflow run "Terraform AWS - Destroy" \
  -f environment=aws-prod \
  -f confirm=destroy
```

**Via GitHub UI:**
1. Go to **Actions** tab in GitHub
2. Select the workflow from left sidebar
3. Click **Run workflow** button
4. Fill in required inputs and click **Run workflow**

## 💡 Best Practices

1. **Always review plans** before merging PRs
2. **Use branch protection** on `main` branch
3. **Require approvals** for production deployments
4. **Tag releases** for tracking deployments
5. **Monitor state files** for unexpected changes
6. **Rotate credentials** regularly (or move to OIDC)
7. **Use modules** for reusable infrastructure patterns

## 🎨 Customization

### Adding New AWS Resources
1. Create or modify modules in `modules/aws/`
2. Reference modules in `environments/aws-dev/main.tf` and `environments/aws-prod/main.tf`
3. Test in dev environment first

### Adding New Azure Resources
1. Create or modify modules in `modules/azure/`
2. Reference modules in `environments/azure-dev/main.tf` and `environments/azure-prod/main.tf`
3. Test in dev environment first

### Adding New Environments
1. Create new folder in `environments/` (e.g., `aws-staging/`)
2. Copy configuration from existing environment
3. Create new GitHub workflow file
4. Update backend configuration

## 🔧 Troubleshooting

### State Lock Issues
```bash
# If state is locked and workflow failed
terraform force-unlock <LOCK_ID>
```

### Backend Access Issues
- Verify AWS credentials have S3 and DynamoDB permissions
- Verify Azure credentials have Storage Account access
- Check backend configuration in `backend.tf`

### Workflow Failures
- Check GitHub Actions logs for detailed error messages
- Verify GitHub Secrets are set correctly
- Ensure backend resources exist (S3 bucket, DynamoDB table, etc.)

## 🤝 Contributing

We welcome contributions from the community! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details on:
- Code of Conduct
- Development process
- Submitting pull requests
- Reporting issues

## 🔒 Security

Security is a top priority. Please review our [Security Policy](SECURITY.md) for:
- Reporting security vulnerabilities
- Security best practices
- Supported versions

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

### Getting Help
- **Documentation**: Check the [docs/](docs/) folder for comprehensive guides
- **Issues**: [Open an issue](https://github.com/iracic82/terraform-github-actions-starter/issues/new/choose) using our templates
- **Discussions**: [GitHub Discussions](https://github.com/iracic82/terraform-github-actions-starter/discussions)

### Quick Links
- [Setup Guide](docs/SETUP.md) - Complete setup instructions
- [Architecture](docs/ARCHITECTURE.md) - System design and components
- [Quick Reference](docs/QUICK_REFERENCE.md) - Command cheat sheet
- [Changelog](CHANGELOG.md) - Version history

## 🎯 Roadmap

### Current (v1.0)
- ✅ Multi-cloud support (AWS, Azure)
- ✅ GitHub Actions workflows
- ✅ Remote state management
- ✅ Dev/Prod environments

### Planned (v2.0)
- ⏳ OIDC authentication examples
- ⏳ GCP support
- ⏳ Terraform Cloud integration
- ⏳ Policy as Code (OPA/Sentinel)

### Future (v3.0)
- 🔮 HashiCorp Vault integration
- 🔮 Multi-region deployments
- 🔮 Automated compliance scanning
- 🔮 Cost optimization recommendations

## 🌟 Star History

If you find this project helpful, please consider giving it a star! ⭐

## 📈 Project Stats

![GitHub repo size](https://img.shields.io/github/repo-size/iracic82/terraform-github-actions-starter)
![GitHub code size](https://img.shields.io/github/languages/code-size/iracic82/terraform-github-actions-starter)
![GitHub last commit](https://img.shields.io/github/last-commit/iracic82/terraform-github-actions-starter)

---

**Made with ❤️ for the Infrastructure as Code community**
