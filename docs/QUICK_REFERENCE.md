# Quick Reference Guide

Cheat sheet for common operations.

## Table of Contents
1. [Common Commands](#common-commands)
2. [Workflow Triggers](#workflow-triggers)
3. [Troubleshooting](#troubleshooting)
4. [Backend Configuration](#backend-configuration)

---

## Common Commands

### Initial Setup

```bash
# Clone repository
git clone https://github.com/YOUR_ORG/terraform-github-actions-starter.git
cd terraform-github-actions-starter

# Open in VS Code
code .

# Setup AWS backend
./scripts/setup-aws-backend.sh

# Setup Azure backend
./scripts/setup-azure-backend.sh
```

### Terraform Operations

```bash
# Navigate to environment
cd environments/aws-dev

# Initialize Terraform
terraform init

# Format code
terraform fmt

# Validate configuration
terraform validate

# Plan changes
terraform plan

# Apply changes
terraform apply

# Destroy resources
terraform destroy

# Show current state
terraform show

# List resources
terraform state list

# Get outputs
terraform output

# Unlock state (if stuck)
terraform force-unlock <LOCK_ID>
```

### GitHub CLI Operations

```bash
# Authenticate
gh auth login

# Create repository
gh repo create my-terraform-infrastructure --private

# Create pull request
gh pr create --title "Deploy new feature" --body "Description"

# List pull requests
gh pr list

# View PR status
gh pr status

# Merge PR
gh pr merge <PR_NUMBER>

# Set secrets
gh secret set AWS_ACCESS_KEY_ID --body "AKIAXXXXXXXX"
gh secret set AWS_SECRET_ACCESS_KEY --body "xxxxxxxx"

# List secrets
gh secret list

# View workflow runs
gh run list

# View workflow logs
gh run view <RUN_ID>

# Watch a running workflow in real-time
gh run watch <RUN_ID>

# Manually trigger a workflow (workflow_dispatch)
gh workflow run "Terraform AWS Prod - Apply"

# Manually trigger destroy workflow with inputs
gh workflow run "Terraform AWS - Destroy" \
  -f environment=aws-prod \
  -f confirm=destroy

# List available workflows
gh workflow list

# View workflow details
gh workflow view "Terraform AWS Prod - Apply"
```

### AWS CLI Operations

```bash
# Configure AWS CLI
aws configure

# Verify credentials
aws sts get-caller-identity

# List S3 buckets
aws s3 ls

# List DynamoDB tables
aws dynamodb list-tables

# Check state bucket
aws s3 ls s3://terraform-state-ACCOUNT_ID-REGION/

# List state file versions
aws s3api list-object-versions \
  --bucket terraform-state-ACCOUNT_ID-REGION \
  --prefix aws-dev/terraform.tfstate
```

### Azure CLI Operations

```bash
# Login to Azure
az login

# List subscriptions
az account list

# Set subscription
az account set --subscription "SUBSCRIPTION_ID"

# Verify login
az account show

# List resource groups
az group list

# List storage accounts
az storage account list

# Check state container
az storage blob list \
  --container-name tfstate \
  --account-name tfstateXXXXXX
```

---

## Workflow Triggers

### How to Trigger Workflows

| Action | Trigger | What Runs |
|--------|---------|-----------|
| Create PR with AWS changes | `pull_request` to `main` | `terraform-aws-dev.yml` (plan) |
| Create PR with Azure changes | `pull_request` to `main` | `terraform-azure-dev.yml` (plan) |
| Merge PR to main (AWS) | `push` to `main` | `terraform-aws-prod.yml` (apply) |
| Merge PR to main (Azure) | `push` to `main` | `terraform-azure-prod.yml` (apply) |

### Typical Development Workflow

```bash
# 1. Create feature branch
git checkout -b feature/add-new-server

# 2. Make changes
cd environments/aws-dev
# Edit main.tf

# 3. Test locally (optional)
terraform init
terraform plan

# 4. Commit and push
git add .
git commit -m "Add new web server to dev"
git push origin feature/add-new-server

# 5. Create PR
gh pr create --title "Add new web server" --body "Adds new EC2 instance"

# 6. Review plan in PR comments
# GitHub Actions automatically runs terraform plan

# 7. Merge PR
gh pr merge --squash

# 8. Production deployment requires approval
# Go to GitHub Actions tab → Review deployments
```

---

## Troubleshooting

### State is Locked

**Problem:** `Error: Error acquiring the state lock`

**Solution:**
```bash
# Check who has the lock (in DynamoDB or Azure Portal)
# If it's a stuck lock from failed workflow:
terraform force-unlock <LOCK_ID>

# For AWS, you can also check DynamoDB
aws dynamodb scan \
  --table-name terraform-state-lock \
  --region us-east-1
```

### Backend Initialization Failed

**Problem:** `Error: Failed to get existing workspaces`

**Solution:**
```bash
# Verify backend configuration in backend.tf
# Check AWS credentials
aws sts get-caller-identity

# Check Azure credentials
az account show

# Re-run backend setup
cd scripts
./setup-aws-backend.sh  # or setup-azure-backend.sh

# Reinitialize
terraform init -reconfigure
```

### GitHub Actions Workflow Failed

**Problem:** Workflow fails with authentication error

**Solution:**
```bash
# Check GitHub Secrets are set
gh secret list

# Verify secrets are correct
# AWS
aws configure list

# Azure
az account show

# Re-set secrets if needed
gh secret set AWS_ACCESS_KEY_ID --body "AKIAXXXXXXXX"
```

### Module Not Found

**Problem:** `Error: Module not installed`

**Solution:**
```bash
# Initialize with module update
terraform init -upgrade

# Or force reinstall
rm -rf .terraform
terraform init
```

### Permission Denied

**Problem:** `Error: UnauthorizedOperation` or `Error: Authorization failed`

**Solution:**
```bash
# AWS - Check IAM permissions
aws iam get-user

# Verify the IAM user/role has necessary permissions

# Azure - Check role assignments
az role assignment list --assignee <CLIENT_ID>
```

---

## Backend Configuration

### AWS Backend Template

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-123456789012-us-east-1"
    key            = "ENVIRONMENT/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    kms_key_id     = "arn:aws:kms:us-east-1:123456789012:key/xxxxx"
  }
}
```

### Azure Backend Template

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstate12345678"
    container_name       = "tfstate"
    key                  = "ENVIRONMENT.terraform.tfstate"
  }
}
```

### Environment-Specific Keys

| Environment | AWS Key | Azure Key |
|-------------|---------|-----------|
| aws-dev | `aws-dev/terraform.tfstate` | - |
| aws-prod | `aws-prod/terraform.tfstate` | - |
| azure-dev | - | `azure-dev.terraform.tfstate` |
| azure-prod | - | `azure-prod.terraform.tfstate` |

---

## GitHub Secrets Required

### For AWS

```bash
gh secret set AWS_ACCESS_KEY_ID --body "AKIAXXXXXXXXXXXXXXXX"
gh secret set AWS_SECRET_ACCESS_KEY --body "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
gh secret set AWS_REGION --body "us-east-1"
```

### For Azure

```bash
gh secret set AZURE_CLIENT_ID --body "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
gh secret set AZURE_CLIENT_SECRET --body "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
gh secret set AZURE_SUBSCRIPTION_ID --body "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
gh secret set AZURE_TENANT_ID --body "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

---

## Useful Links

- **Terraform Docs**: https://www.terraform.io/docs
- **AWS Provider**: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- **Azure Provider**: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
- **GitHub Actions**: https://docs.github.com/en/actions
- **AWS CLI**: https://docs.aws.amazon.com/cli/
- **Azure CLI**: https://docs.microsoft.com/en-us/cli/azure/

---

## Emergency Procedures

### Rollback Production

```bash
# Option 1: Revert the commit
git revert HEAD
git push origin main

# Option 2: Restore previous state version (AWS)
aws s3api list-object-versions \
  --bucket terraform-state-xxx \
  --prefix aws-prod/terraform.tfstate

aws s3api get-object \
  --bucket terraform-state-xxx \
  --key aws-prod/terraform.tfstate \
  --version-id <VERSION_ID> \
  backup.tfstate

# Option 3: Destroy and recreate
cd environments/aws-prod
terraform destroy
# Fix the issue
terraform apply
```

### State File Corruption

```bash
# 1. Download backup from S3/Azure
# 2. Validate the backup
terraform state list -state=backup.tfstate

# 3. Replace current state (carefully!)
mv terraform.tfstate terraform.tfstate.corrupted
cp backup.tfstate terraform.tfstate

# 4. Verify
terraform state list
terraform plan
```

---

## Performance Tips

### Speed Up Terraform

```bash
# Use parallel execution (default: 10)
terraform apply -parallelism=20

# Skip refresh for large infrastructures
terraform plan -refresh=false

# Target specific resources
terraform apply -target=module.web_server
```

### Cache Terraform Plugins

```bash
# Create plugin cache directory
mkdir -p ~/.terraform.d/plugin-cache

# Configure in ~/.terraformrc
cat > ~/.terraformrc << 'EOF'
plugin_cache_dir = "$HOME/.terraform.d/plugin-cache"
EOF
```

---

## Contact & Support

- **GitHub Issues**: https://github.com/YOUR_ORG/terraform-github-actions-starter/issues
- **Documentation**: See `docs/` folder
- **Team Chat**: [Your team's Slack/Teams channel]
