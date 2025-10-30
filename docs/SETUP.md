# Complete Setup Guide

This guide walks you through the complete setup process from scratch.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [VS Code Setup](#vs-code-setup)
3. [GitHub Setup](#github-setup)
4. [Clone the Repository](#clone-the-repository)
5. [AWS Backend Setup](#aws-backend-setup)
6. [Azure Backend Setup](#azure-backend-setup)
7. [Configure GitHub Secrets](#configure-github-secrets)
8. [Test the Setup](#test-the-setup)

---

## Prerequisites

### Required Tools

Install the following tools on your workstation:

1. **Git**
   ```bash
   # macOS
   brew install git

   # Windows
   # Download from https://git-scm.com/download/win

   # Linux (Ubuntu/Debian)
   sudo apt-get install git
   ```

2. **VS Code**
   - Download from https://code.visualstudio.com/
   - Install the following extensions:
     - HashiCorp Terraform
     - GitHub Pull Requests and Issues
     - GitLens
     - Azure Terraform (optional)

3. **AWS CLI**
   ```bash
   # macOS
   brew install awscli

   # Windows
   # Download from https://aws.amazon.com/cli/

   # Linux
   curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   unzip awscliv2.zip
   sudo ./aws/install
   ```

4. **Azure CLI** (if using Azure)
   ```bash
   # macOS
   brew install azure-cli

   # Windows
   # Download from https://aka.ms/installazurecliwindows

   # Linux
   curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
   ```

5. **Terraform**
   ```bash
   # macOS
   brew install terraform

   # Windows (with Chocolatey)
   choco install terraform

   # Linux
   wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
   unzip terraform_1.6.0_linux_amd64.zip
   sudo mv terraform /usr/local/bin/
   ```

6. **GitHub CLI** (optional but recommended)
   ```bash
   # macOS
   brew install gh

   # Windows
   choco install gh

   # Linux
   type -p curl >/dev/null || sudo apt install curl -y
   curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
   sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
   echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
   sudo apt update
   sudo apt install gh -y
   ```

### Required Accounts

- **GitHub Account** - https://github.com/signup
- **AWS Account** - https://aws.amazon.com/
- **Azure Account** (if using Azure) - https://azure.microsoft.com/free/

---

## VS Code Setup

### Install VS Code Extensions

1. Open VS Code
2. Press `Cmd+Shift+X` (macOS) or `Ctrl+Shift+X` (Windows/Linux)
3. Search and install:
   - **HashiCorp Terraform** - Syntax highlighting, IntelliSense
   - **GitHub Pull Requests and Issues** - Manage PRs from VS Code
   - **GitLens** - Enhanced Git capabilities
   - **Azure Terraform** - Azure-specific Terraform support (optional)

### Configure Terraform Extension

1. Open VS Code Settings: `Cmd+,` (macOS) or `Ctrl+,` (Windows/Linux)
2. Search for "Terraform"
3. Configure:
   - ✅ Enable `terraform.languageServer.enable`
   - ✅ Enable `terraform.experimentalFeatures.validateOnSave`
   - Set `terraform.languageServer.path` if needed

---

## GitHub Setup

### Connect VS Code to GitHub

#### Method 1: Using VS Code Built-in GitHub Integration

1. **Open VS Code**
2. **Click on the Accounts icon** (bottom left corner)
3. **Click "Sign in to Sync Settings"**
4. **Select "Sign in with GitHub"**
5. **Authorize VS Code** in the browser
6. **Return to VS Code** - You're now connected!

#### Method 2: Using GitHub CLI

```bash
# Authenticate with GitHub
gh auth login

# Follow the prompts:
# 1. Select "GitHub.com"
# 2. Select "HTTPS"
# 3. Authenticate via web browser
# 4. Complete authentication
```

#### Method 3: Using Git Credential Manager

```bash
# Configure Git
git config --global user.name "Your Name"
git config --global user.email "your.email@company.com"

# First time you push, you'll be prompted for GitHub credentials
# Use a Personal Access Token (PAT) instead of password
```

### Create GitHub Personal Access Token (PAT)

If you need a token for authentication:

1. Go to https://github.com/settings/tokens
2. Click **"Generate new token"** → **"Generate new token (classic)"**
3. Give it a name: `Terraform Automation`
4. Select scopes:
   - ✅ `repo` (Full control of private repositories)
   - ✅ `workflow` (Update GitHub Action workflows)
   - ✅ `admin:org` (if working with organization repos)
5. Click **"Generate token"**
6. **COPY THE TOKEN** - You won't see it again!
7. Use this token as your password when prompted

### Create GitHub Repository

#### Option 1: Using GitHub CLI

```bash
# Create a new private repository
gh repo create my-terraform-infrastructure --private --clone

# Or create from template
gh repo create my-terraform-infrastructure --template iracic82/terraform-github-actions-starter --private --clone
```

#### Option 2: Using GitHub Web UI

1. Go to https://github.com/new
2. Repository name: `my-terraform-infrastructure`
3. Description: `Infrastructure as Code with Terraform and GitHub Actions`
4. Visibility: **Private** (recommended)
5. Initialize: **Do NOT initialize** (we'll push our code)
6. Click **"Create repository"**

---

## Clone the Repository

### Clone Template Repository

```bash
# Navigate to your projects directory
cd ~/projects

# Clone this template repository
git clone https://github.com/iracic82/terraform-github-actions-starter.git my-terraform-infrastructure

# Navigate into the directory
cd my-terraform-infrastructure

# Open in VS Code
code .
```

### Connect to Your GitHub Repository

```bash
# Remove the template remote
git remote remove origin

# Add your new repository as remote
git remote add origin https://github.com/YOUR_USERNAME/my-terraform-infrastructure.git

# Push the code
git branch -M main
git push -u origin main
```

### Verify Connection

```bash
# Check remote
git remote -v

# Should show:
# origin  https://github.com/YOUR_USERNAME/my-terraform-infrastructure.git (fetch)
# origin  https://github.com/YOUR_USERNAME/my-terraform-infrastructure.git (push)
```

---

## AWS Backend Setup

The AWS backend uses **S3 for state storage** and **DynamoDB for state locking**.

### Why AWS S3 + DynamoDB?

- **S3**: Stores Terraform state files with versioning and encryption
- **DynamoDB**: Provides state locking to prevent concurrent modifications
- **KMS**: Encrypts state files at rest with customer-managed keys
- **Cloud-Native**: Keeps AWS infrastructure state in AWS for security and performance

### Run the Setup Script

```bash
# Make sure you're authenticated to AWS
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Enter your default region (e.g., us-east-1)

# Run the backend setup script
cd scripts
./setup-aws-backend.sh

# Follow the prompts
# This creates:
# - S3 bucket: terraform-state-ACCOUNT_ID-REGION
# - DynamoDB table: terraform-state-lock
# - KMS key for encryption
```

### Update Backend Configuration

After the script completes, it will output the backend configuration:

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-123456789012-us-east-1"
    key            = "aws-dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    kms_key_id     = "arn:aws:kms:us-east-1:123456789012:key/xxxxx"
  }
}
```

**Update the following files:**

1. `environments/aws-dev/backend.tf`
2. `environments/aws-prod/backend.tf`

Replace the placeholder values with the actual values from the script output.

### Initialize Terraform

```bash
# Navigate to AWS dev environment
cd ../environments/aws-dev

# Initialize Terraform with the backend
terraform init

# You should see: "Successfully configured the backend "s3"!"
```

---

## Azure Backend Setup

The Azure backend uses **Azure Storage Account** for state storage with built-in locking.

### Why Azure Storage?

- **Blob Storage**: Stores Terraform state files with versioning
- **Built-in Locking**: Azure Storage provides native lease-based locking
- **Encryption**: State files encrypted at rest automatically
- **Cloud-Native**: Keeps Azure infrastructure state in Azure for security and performance

### Run the Setup Script

```bash
# Make sure you're authenticated to Azure
az login
az account set --subscription "YOUR_SUBSCRIPTION_NAME_OR_ID"

# Run the backend setup script
cd ../../scripts
./setup-azure-backend.sh

# Follow the prompts
# This creates:
# - Resource Group: terraform-state-rg
# - Storage Account: tfstateXXXXXXXX (globally unique)
# - Container: tfstate
# - Service Principal (optional)
```

### Update Backend Configuration

After the script completes, it will output the backend configuration:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstate12345678"
    container_name       = "tfstate"
    key                  = "azure-dev.terraform.tfstate"
  }
}
```

**Update the following files:**

1. `environments/azure-dev/backend.tf`
2. `environments/azure-prod/backend.tf`

Replace the placeholder `tfstateXXXXX` with the actual storage account name.

### Initialize Terraform

```bash
# Navigate to Azure dev environment
cd ../environments/azure-dev

# Initialize Terraform with the backend
terraform init

# You should see: "Successfully configured the backend "azurerm"!"
```

---

## Understanding Remote State Architecture

### Why Two Separate Backends?

This template uses **TWO separate remote state backends**:

```
AWS Environments → S3 + DynamoDB Backend
├── aws-dev/     → s3://terraform-state-xxx/aws-dev/
└── aws-prod/    → s3://terraform-state-xxx/aws-prod/

Azure Environments → Azure Storage Backend
├── azure-dev/   → azurerm://tfstate-xxx/azure-dev.tfstate
└── azure-prod/  → azurerm://tfstate-xxx/azure-prod.tfstate
```

### Why NOT One Backend for Everything?

**Security Benefits:**
- **Principle of Least Privilege**: AWS credentials don't need Azure access and vice versa
- **Blast Radius Reduction**: Compromise of one cloud doesn't affect the other
- **Compliance**: Some regulations require cloud isolation

**Performance Benefits:**
- **Lower Latency**: State stored in the same region as resources
- **Faster Operations**: No cross-cloud network hops

**Operational Benefits:**
- **Cloud-Native Features**: Use AWS KMS for AWS, Azure Key Vault for Azure
- **Native Tooling**: AWS CloudTrail for S3 audit, Azure Monitor for Storage
- **Simpler IAM**: No cross-cloud service principals or role assumptions

**Cost Benefits:**
- **No Egress Charges**: State doesn't cross cloud boundaries
- **Cheaper Storage**: Using each cloud's native storage is most cost-effective

### What if You Only Use One Cloud?

If you only use AWS or Azure, you can:
- Delete the unused environment folders
- Remove unused GitHub workflows
- Only run one backend setup script

---

## Configure GitHub Secrets

GitHub Secrets are used to securely store cloud credentials for GitHub Actions.

### Access GitHub Repository Settings

1. Go to your GitHub repository
2. Click **Settings** tab
3. In the left sidebar, click **Secrets and variables** → **Actions**
4. Click **New repository secret**

### AWS Secrets

Add the following secrets for AWS:

| Secret Name | Value | How to Get |
|-------------|-------|------------|
| `AWS_ACCESS_KEY_ID` | Your AWS access key | `aws configure get aws_access_key_id` |
| `AWS_SECRET_ACCESS_KEY` | Your AWS secret key | `aws configure get aws_secret_access_key` |
| `AWS_REGION` | Your AWS region | Example: `us-east-1` |

#### Creating AWS IAM User for GitHub Actions

```bash
# Create IAM user
aws iam create-user --user-name github-actions-terraform

# Create access key
aws iam create-access-key --user-name github-actions-terraform

# Attach policy (adjust permissions as needed)
aws iam attach-user-policy \
  --user-name github-actions-terraform \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

# IMPORTANT: Save the AccessKeyId and SecretAccessKey from the output!
```

### Azure Secrets

Add the following secrets for Azure:

| Secret Name | Value | How to Get |
|-------------|-------|------------|
| `AZURE_CLIENT_ID` | Service Principal App ID | From `setup-azure-backend.sh` output |
| `AZURE_CLIENT_SECRET` | Service Principal Password | From `setup-azure-backend.sh` output |
| `AZURE_SUBSCRIPTION_ID` | Your subscription ID | `az account show --query id -o tsv` |
| `AZURE_TENANT_ID` | Your tenant ID | `az account show --query tenantId -o tsv` |

#### Creating Azure Service Principal

```bash
# Get your subscription ID
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

# Create service principal
az ad sp create-for-rbac \
  --name "github-actions-terraform" \
  --role Contributor \
  --scopes "/subscriptions/$SUBSCRIPTION_ID" \
  --sdk-auth

# Save the output - you'll need:
# - clientId → AZURE_CLIENT_ID
# - clientSecret → AZURE_CLIENT_SECRET
# - subscriptionId → AZURE_SUBSCRIPTION_ID
# - tenantId → AZURE_TENANT_ID
```

### Using GitHub CLI to Set Secrets

```bash
# AWS Secrets
gh secret set AWS_ACCESS_KEY_ID --body "YOUR_ACCESS_KEY_ID"
gh secret set AWS_SECRET_ACCESS_KEY --body "YOUR_SECRET_ACCESS_KEY"
gh secret set AWS_REGION --body "us-east-1"

# Azure Secrets
gh secret set AZURE_CLIENT_ID --body "YOUR_CLIENT_ID"
gh secret set AZURE_CLIENT_SECRET --body "YOUR_CLIENT_SECRET"
gh secret set AZURE_SUBSCRIPTION_ID --body "YOUR_SUBSCRIPTION_ID"
gh secret set AZURE_TENANT_ID --body "YOUR_TENANT_ID"
```

---

## Test the Setup

### Configure GitHub Environments (Production Protection)

1. Go to your GitHub repository
2. Click **Settings** → **Environments**
3. Click **New environment**
4. Name: `aws-production`
5. Check **Required reviewers**
6. Add yourself or team members as reviewers
7. Click **Save protection rules**
8. Repeat for `azure-production`

### Test AWS Deployment

```bash
# Navigate to AWS dev environment
cd environments/aws-dev

# Make a small change (optional)
# Edit main.tf and change instance_name

# Commit and push
git checkout -b test-aws-deployment
git add .
git commit -m "Test AWS deployment"
git push origin test-aws-deployment

# Create pull request
gh pr create --title "Test AWS deployment" --body "Testing GitHub Actions workflow"
```

**Expected Result:**
- GitHub Actions automatically runs `terraform plan`
- Plan is posted as a comment on the PR
- Review the plan and merge the PR

### Test Azure Deployment

```bash
# Navigate to Azure dev environment
cd environments/azure-dev

# Make a small change (optional)
# Edit main.tf and change instance_name

# Commit and push
git checkout -b test-azure-deployment
git add .
git commit -m "Test Azure deployment"
git push origin test-azure-deployment

# Create pull request
gh pr create --title "Test Azure deployment" --body "Testing GitHub Actions workflow"
```

**Expected Result:**
- GitHub Actions automatically runs `terraform plan`
- Plan is posted as a comment on the PR
- Review the plan and merge the PR

### Verify Production Approval Gate

When you merge to `main`, the production workflow runs:
- GitHub Actions will wait for manual approval
- Go to **Actions** tab in GitHub
- Click on the running workflow
- Click **Review deployments**
- Select the environment and approve
- Terraform apply runs

### Manually Trigger Workflows

You can manually trigger workflows using GitHub CLI or the GitHub UI:

#### Using GitHub CLI

```bash
# Trigger production workflow manually
gh workflow run "Terraform AWS Prod - Apply"

# Trigger destroy workflow with confirmation
gh workflow run "Terraform AWS - Destroy" \
  -f environment=aws-prod \
  -f confirm=destroy

# List all available workflows
gh workflow list

# View recent workflow runs
gh run list

# Watch a workflow in real-time
gh run watch <RUN_ID>
```

#### Using GitHub UI

1. Go to your GitHub repository
2. Click the **Actions** tab
3. Select the workflow from the left sidebar
4. Click **Run workflow** button (top right)
5. Select branch and fill in any required inputs
6. Click **Run workflow**

**Available Manual Workflows:**
- `Terraform AWS Prod - Apply` - Deploy to AWS production
- `Terraform Azure Prod - Apply` - Deploy to Azure production
- `Terraform AWS - Destroy` - Destroy AWS infrastructure (requires confirmation)

---

## Troubleshooting

### VS Code Cannot Connect to GitHub

**Problem:** VS Code says "Authentication failed"

**Solution:**
1. Sign out of GitHub in VS Code
2. Sign in again
3. Or use GitHub CLI: `gh auth login`

### Git Push Asks for Password

**Problem:** Git keeps asking for username and password

**Solution:**
```bash
# Use Personal Access Token instead of password
# Or configure credential helper
git config --global credential.helper store
```

### AWS CLI Not Configured

**Problem:** `aws` command not found or not configured

**Solution:**
```bash
# Check if installed
aws --version

# Configure
aws configure
```

### Azure CLI Not Logged In

**Problem:** `az` command says not authenticated

**Solution:**
```bash
# Login
az login

# Set subscription
az account set --subscription "YOUR_SUBSCRIPTION"

# Verify
az account show
```

### Terraform Backend Initialization Failed

**Problem:** `terraform init` fails with backend error

**Solution:**
1. Verify backend configuration in `backend.tf`
2. Check AWS/Azure credentials
3. Verify S3 bucket or Azure Storage account exists
4. Run the setup scripts again

### GitHub Actions Workflow Failed

**Problem:** Workflow runs but fails

**Solution:**
1. Check GitHub Actions logs
2. Verify GitHub Secrets are set correctly
3. Check AWS/Azure permissions
4. Verify backend configuration

---

## Next Steps

1. Read [ARCHITECTURE.md](ARCHITECTURE.md) to understand the system design
2. Customize the infrastructure for your needs
3. Plan your migration to OIDC (Phase 2) - see [PHASE_EXPANSION.md](PHASE_EXPANSION.md)
4. Set up monitoring and alerting
5. Document your specific deployment procedures

---

## Support

- GitHub Issues: https://github.com/iracic82/terraform-github-actions-starter/issues
- Terraform Docs: https://www.terraform.io/docs
- AWS Terraform Provider: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- Azure Terraform Provider: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
