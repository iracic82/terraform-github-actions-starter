# Terraform GitHub Actions Starter Template

A production-ready template for managing infrastructure as code using Terraform and GitHub Actions. This template demonstrates best practices for multi-cloud deployments (AWS and Azure) with custom modules, environment separation, and automated CI/CD workflows.

## Features

- **Multi-Cloud Support**: Deploy to both AWS and Azure
- **Custom Terraform Modules**: Reusable modules for VPC, EC2, VNet, VMs, Security Groups, and NSGs
- **Environment Separation**: Dedicated dev and prod environments with isolated state
- **GitHub Actions CI/CD**: Automated plan on PR, apply on merge with approval gates
- **Remote State Management**: S3 + DynamoDB for AWS, Azure Storage for Azure
- **Phase-Based Implementation**: Start simple with GitHub Secrets, expand to OIDC and Vault
- **PR Approval Workflow**: Automated planning on pull requests, manual approval for production

## Quick Start

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

## Project Structure

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

## Deployment Phases

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

## Documentation

- [Detailed Setup Guide](docs/SETUP.md) - Step-by-step setup instructions
- [Architecture Overview](docs/ARCHITECTURE.md) - System design and components
- [Phase Expansion Guide](docs/PHASE_EXPANSION.md) - How to expand to OIDC and Vault

## Workflows Explained

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

## Best Practices

1. **Always review plans** before merging PRs
2. **Use branch protection** on `main` branch
3. **Require approvals** for production deployments
4. **Tag releases** for tracking deployments
5. **Monitor state files** for unexpected changes
6. **Rotate credentials** regularly (or move to OIDC)
7. **Use modules** for reusable infrastructure patterns

## Customization

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

## Troubleshooting

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

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

MIT License - See LICENSE file for details

## Support

For issues and questions:
- Check [docs/SETUP.md](docs/SETUP.md) for detailed setup help
- Review GitHub Actions logs for error details
- Open an issue in the repository

## Next Steps

After successful setup:
1. Review [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) to understand the system
2. Plan your migration to OIDC (Phase 2) using [docs/PHASE_EXPANSION.md](docs/PHASE_EXPANSION.md)
3. Customize modules for your specific infrastructure needs
4. Set up monitoring and alerting for your infrastructure
