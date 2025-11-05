# Complete Setup Guide

This guide walks you through the complete setup process from scratch.

## 👥 Which Guide Should I Use?

**Choose the right guide based on your role:**

| Your Situation | Guide to Follow | What You'll Do |
|----------------|-----------------|----------------|
| 🚀 **First team member** creating a new project from this template | **This guide (SETUP.md)** | Clone template, create new repo, set up backend, configure secrets |
| 👤 **Additional team member** joining an existing project | **[TEAM_MEMBER_SETUP.md](TEAM_MEMBER_SETUP.md)** | Clone existing repo, configure local credentials, start working |

**⚠️ Important:** If someone on your team already set up the project, DO NOT follow this guide! Use [TEAM_MEMBER_SETUP.md](TEAM_MEMBER_SETUP.md) instead to avoid creating duplicate resources.

---

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [VS Code Setup](#vs-code-setup)
3. [GitHub Setup](#github-setup)
4. [Clone the Repository](#clone-the-repository)
5. [AWS Backend Setup](#aws-backend-setup)
6. [Azure Backend Setup](#azure-backend-setup)
7. [Configure GitHub Secrets](#configure-github-secrets)
8. [Test the Setup](#test-the-setup)
9. [How It All Works - Visual Guide](#how-it-all-works---visual-guide)
10. [Frequently Asked Questions](#frequently-asked-questions)
11. [Cleanup / Uninstall](#cleanup--uninstall)

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

### Preflight Checklist

Before starting, verify you have:

- [ ] GitHub account with repository creation permissions
- [ ] AWS account (or Azure subscription if using Azure)
- [ ] Terminal/command line access
- [ ] Text editor installed (VS Code recommended)
- [ ] 30-60 minutes of uninterrupted time

**Quick Verification - Check Installed Tools:**

```bash
# Run these commands to verify installations
git --version        # Should show: git version 2.x.x
terraform --version  # Should show: Terraform v1.6.x or higher
aws --version        # Should show: aws-cli/2.x.x (if using AWS)
az --version         # Should show: azure-cli 2.x.x (if using Azure)
gh --version         # Should show: gh version 2.x.x (optional but recommended)
```

**Expected Output:** All commands should return version numbers without errors.

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

> 📍 **Starting Location:** Any directory (we'll navigate to projects folder)
> ⏱️ **Estimated Time:** 2 minutes

### Clone Template Repository

```bash
# Navigate to your projects directory (create if it doesn't exist)
mkdir -p ~/projects
cd ~/projects

# Verify you're in the right place
pwd  # Should show: /Users/yourname/projects (or /home/yourname/projects on Linux)

# Clone this template repository
git clone https://github.com/iracic82/terraform-github-actions-starter.git my-terraform-infrastructure

# Navigate into the directory
cd my-terraform-infrastructure

# Verify the clone was successful
ls -la  # Should show: .github/, modules/, environments/, scripts/, docs/, README.md

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

> 📍 **Starting Location:** Project root (`~/projects/my-terraform-infrastructure`)
> ⏱️ **Estimated Time:** 5 minutes

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

# Verify AWS credentials work
aws sts get-caller-identity
# Should show your Account ID, UserId, and ARN

# From project root, navigate to scripts directory
pwd  # Should show: /path/to/my-terraform-infrastructure
cd scripts

# Run the backend setup script
./setup-aws-backend.sh

# Follow the prompts
# This creates:
# - S3 bucket: terraform-state-ACCOUNT_ID-REGION
# - DynamoDB table: terraform-state-lock
# - KMS key for encryption
```

**✅ Success Indicators:**

After the script completes, you should see:
```
✓ S3 bucket created: terraform-state-123456789012-us-east-1
✓ DynamoDB table created: terraform-state-lock
✓ KMS key created: arn:aws:kms:us-east-1:123456789012:key/xxxxx
```

**📋 Important:** Copy the KMS key ID from the output - you'll need it in the next step!

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
# Navigate back to project root, then to AWS dev environment
cd ~/projects/my-terraform-infrastructure/environments/aws-dev

# Verify you're in the right directory
pwd  # Should show: /path/to/my-terraform-infrastructure/environments/aws-dev

# Initialize Terraform with the backend
terraform init
```

**✅ Success Indicators:**

You should see output containing:
```
Initializing the backend...
Successfully configured the backend "s3"!

Initializing modules...
Initializing provider plugins...

Terraform has been successfully initialized!
```

**❌ If you see errors:**
- `Error: Failed to get existing workspaces` → Check AWS credentials with `aws sts get-caller-identity`
- `Error: NoSuchBucket` → Verify bucket name in `backend.tf` matches the script output
- `Error: AccessDenied` → Check IAM permissions for S3 and DynamoDB access

---

## Azure Backend Setup

> 📍 **Starting Location:** Project root (`~/projects/my-terraform-infrastructure`)
> ⏱️ **Estimated Time:** 5 minutes

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

# Verify Azure credentials
az account show
# Should show your subscription details

# From project root, navigate to scripts directory
cd ~/projects/my-terraform-infrastructure/scripts

# Run the backend setup script
./setup-azure-backend.sh

# Follow the prompts
# This creates:
# - Resource Group: terraform-state-rg
# - Storage Account: tfstateXXXXXXXX (globally unique)
# - Container: tfstate
# - Service Principal (optional)
```

**✅ Success Indicators:**

After the script completes, you should see:
```
✓ Resource Group created: terraform-state-rg
✓ Storage Account created: tfstate12345678
✓ Container created: tfstate
```

**📋 Important:** Copy the storage account name from the output - you'll need it in the next step!

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
cd ~/projects/my-terraform-infrastructure/environments/azure-dev

# Verify you're in the right directory
pwd  # Should show: /path/to/my-terraform-infrastructure/environments/azure-dev

# Initialize Terraform with the backend
terraform init
```

**✅ Success Indicators:**

You should see output containing:
```
Initializing the backend...
Successfully configured the backend "azurerm"!

Initializing modules...
Initializing provider plugins...

Terraform has been successfully initialized!
```

**❌ If you see errors:**
- `Error: Failed to get existing workspaces` → Check Azure credentials with `az account show`
- `Error: Storage account not found` → Verify storage account name in `backend.tf` matches the script output
- `Error: Authorization failed` → Check Azure service principal permissions

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

> 📍 **Starting Location:** Project root (`~/projects/my-terraform-infrastructure`)
> ⏱️ **Estimated Time:** 10-15 minutes

### Pre-Deployment Validation Checklist

Before testing the workflows, verify your setup is complete:

```bash
# Run these validation commands from project root
cd ~/projects/my-terraform-infrastructure

# 1. Verify backend connection (AWS)
cd environments/aws-dev
terraform init
terraform validate
# Should show: Success! The configuration is valid.

# 2. Verify GitHub secrets are set
cd ~/projects/my-terraform-infrastructure
gh secret list
# Should show: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION (and Azure if configured)

# 3. Verify GitHub workflows exist
ls -la .github/workflows/
# Should show: terraform-aws-dev.yml, terraform-aws-prod.yml, terraform-aws-destroy.yml

# 4. Verify git remote is correct
git remote -v
# Should show: origin https://github.com/YOUR_USERNAME/my-terraform-infrastructure.git
```

**✅ All checks passed?** Proceed to live workflow test below.

### Configure GitHub Environments (Production Protection)

**Important:** Set up approval gates before testing to prevent accidental deployments.

1. Go to your GitHub repository: `https://github.com/YOUR_USERNAME/my-terraform-infrastructure`
2. Click **Settings** → **Environments**
3. Click **New environment**
4. Name: `aws-production`
5. Check **Required reviewers**
6. Add yourself or team members as reviewers
7. Click **Save protection rules**
8. Repeat for `azure-production` (if using Azure)

### Live Workflow Test - AWS

**Step 1: Create Test Branch**

```bash
cd ~/projects/my-terraform-infrastructure
git checkout -b test/validate-setup
```

**Step 2: Make a Safe Change**

```bash
# Make a harmless change that won't create resources
echo "  # Test comment - validating GitHub Actions" >> environments/aws-dev/main.tf
```

**Step 3: Commit and Push**

```bash
git add environments/aws-dev/main.tf
git commit -m "test: validate GitHub Actions workflow"
git push -u origin test/validate-setup
```

**Step 4: Create Pull Request**

```bash
gh pr create --title "Test: Validate Setup" --body "Testing automated terraform plan workflow"
```

**Step 5: Watch Workflow Run**

```bash
# Option 1: Watch in real-time
gh run watch

# Option 2: Check status
gh run list --limit 3
```

**✅ Success Indicators:**

You should see workflow complete with these steps:
```
✓ Checkout code
✓ Configure AWS Credentials
✓ Setup Terraform
✓ Terraform Format Check
✓ Terraform Init
✓ Terraform Validate
✓ Terraform Plan
✓ Update Pull Request (plan posted as comment)
```

**Step 6: Verify Plan in PR**

```bash
# View the PR (will open in browser)
gh pr view --web

# Or view in terminal
gh pr view
```

Look for the terraform plan output in the PR comments.

**Step 7: Cleanup Test**

```bash
# Close the PR (don't merge)
gh pr close test/validate-setup

# Switch back to main
git checkout main

# Delete test branch
git branch -D test/validate-setup
```

### Production Approval Gate Test (Optional)

**⚠️ Warning:** This will attempt to deploy to production. Only proceed if you want to test the full workflow.

**When you merge a PR to `main`, the production workflow triggers:**

1. Go to **Actions** tab: `https://github.com/YOUR_USERNAME/my-terraform-infrastructure/actions`
2. You'll see the workflow waiting for approval
3. Click on the running workflow
4. Click **Review deployments**
5. Select the environment (`aws-production`)
6. Click **Approve and deploy**
7. Terraform apply runs after approval

**To test without deploying:** Just verify the workflow shows "Waiting for approval" status, then cancel it.

### Manual Workflow Triggers

#### Using GitHub CLI

```bash
# List all available workflows
gh workflow list

# View recent workflow runs
gh run list

# Watch a workflow in real-time
gh run watch

# Manually trigger production workflow (will wait for approval)
gh workflow run "Terraform AWS Prod - Apply"

# Manually trigger destroy workflow (requires confirmation input)
gh workflow run "Terraform AWS - Destroy" \
  -f environment=aws-prod \
  -f confirm=destroy
```

#### Using GitHub UI

1. Go to repository: `https://github.com/YOUR_USERNAME/my-terraform-infrastructure`
2. Click **Actions** tab
3. Select workflow from left sidebar
4. Click **Run workflow** button (top right)
5. Select branch and fill in any required inputs
6. Click **Run workflow**

**Available Manual Workflows:**
- `Terraform AWS Prod - Apply` - Deploy to AWS production
- `Terraform Azure Prod - Apply` - Deploy to Azure production
- `Terraform AWS - Destroy` - Destroy AWS infrastructure (requires confirmation)

### Validation Complete! 🎉

If all tests passed:
- ✅ Backend is configured correctly
- ✅ GitHub Actions can authenticate to AWS/Azure
- ✅ Terraform plan runs automatically on PRs
- ✅ Approval gates protect production
- ✅ Your infrastructure-as-code pipeline is ready!

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

## How It All Works - Visual Guide

### Development Workflow Diagram

```
┌─────────────────────────────────────────────────────────┐
│ 1. Developer Makes Changes Locally                     │
│    ├─ Edit: environments/aws-dev/main.tf                │
│    ├─ Test: terraform plan (optional)                   │
│    └─ Commit: git commit -m "add new server"            │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│ 2. Push to GitHub (Feature Branch)                     │
│    └─ git push origin feature/new-server                │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│ 3. Create Pull Request                                  │
│    └─ gh pr create --title "Add new server"             │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│ ⚡ 4. GitHub Actions AUTOMATIC TRIGGER                  │
│    ├─ Workflow: terraform-aws-dev.yml                   │
│    ├─ Runs: terraform plan (NO approval needed)         │
│    └─ Posts: Plan results as PR comment                 │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│ 5. Team Reviews PR                                      │
│    ├─ Review: Terraform plan output                     │
│    ├─ Approve: Code review                              │
│    └─ Merge: PR to main branch                          │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│ ⚡ 6. GitHub Actions AUTOMATIC TRIGGER                  │
│    ├─ Workflow: terraform-aws-prod.yml                  │
│    ├─ Waits: Manual approval required ⏸️                │
│    └─ After approval: terraform apply                   │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│ ✅ 7. Infrastructure Deployed to AWS                    │
│    ├─ State: Saved to S3                                │
│    ├─ Lock: Released in DynamoDB                        │
│    └─ Notification: Workflow completes                  │
└─────────────────────────────────────────────────────────┘
```

### State Management Flow

```
Terraform Command → Acquire Lock (DynamoDB)
                           ↓
                   Read State (S3)
                           ↓
            Modify Infrastructure (AWS/Azure)
                           ↓
                   Write State (S3)
                           ↓
                Release Lock (DynamoDB)
```

### PR vs Merge Behavior

| Event | Trigger | Workflow | Approval? | Action |
|-------|---------|----------|-----------|--------|
| Create PR | `pull_request` | `terraform-aws-dev.yml` | ❌ No | `terraform plan` |
| Merge to main | `push` to `main` | `terraform-aws-prod.yml` | ✅ Yes | `terraform apply` |

---

## Frequently Asked Questions

### General Questions

**Q: Can I use this with GitLab or Bitbucket instead of GitHub?**

A: The Terraform modules and structure work anywhere, but you'll need to adapt the CI/CD workflows. GitHub Actions workflows (.yml files) are GitHub-specific. For GitLab, convert to `.gitlab-ci.yml`. For Bitbucket, use `bitbucket-pipelines.yml`.

**Q: Can I manage multiple environments (dev/staging/prod)?**

A: Yes! Create additional folders in `environments/` (e.g., `aws-staging/`) with their own `backend.tf` and `main.tf`. Duplicate and modify the GitHub workflows for the new environment.

**Q: Do I need separate AWS accounts for dev and prod?**

A: Recommended for security and blast radius reduction, but not required. You can use the same account with different regions, VPCs, or resource tagging. Update the backend bucket names accordingly.

**Q: How much does this cost to run?**

A: Minimal infrastructure costs:
- **S3 storage**: ~$0.023/GB/month (state files are typically < 1 MB)
- **DynamoDB**: Free tier covers 25 GB storage (state locks use negligible space)
- **KMS**: ~$1/month per key
- **EC2/Azure VMs**: Depends on what you deploy (t2.micro eligible for AWS free tier)

**Q: Can I use Terraform Cloud instead of S3/Azure Storage?**

A: Yes! Replace the S3/Azure backend configuration with Terraform Cloud remote backend. You'll still use the same modules and GitHub Actions workflows.

### Workflow Questions

**Q: What happens if two people push at the same time?**

A: DynamoDB (AWS) or lease-based locking (Azure) prevents concurrent modifications. The second person will see "state is locked" and must wait for the first operation to complete.

**Q: Can I skip the manual approval for production?**

A: Yes, but **not recommended**. Remove the `environment: aws-production` line from `terraform-aws-prod.yml`. However, this removes the safety gate preventing accidental deployments.

**Q: How do I rollback a deployment?**

A: Three options:
1. **Revert commit**: `git revert HEAD && git push` (triggers new workflow with previous code)
2. **Restore state**: Download previous state version from S3/Azure and manually restore
3. **Fix forward**: Create PR with corrected configuration

**Q: Can I run terraform locally instead of GitHub Actions?**

A: Yes! The backend configuration works locally. Just ensure you have AWS/Azure credentials configured:
```bash
cd environments/aws-dev
terraform init
terraform plan
terraform apply
```

### Security Questions

**Q: Are GitHub Secrets secure?**

A: Yes, GitHub encrypts secrets at rest and in transit. They're never exposed in logs. However, rotating to OIDC (Phase 2) is more secure as it eliminates static credentials entirely.

**Q: What permissions does the GitHub Actions user need?**

A: For the examples in this template:
- **AWS**: EC2, VPC, S3, DynamoDB, KMS access
- **Azure**: Contributor role on subscription

For production, follow least privilege - grant only permissions for resources you manage.

**Q: Can someone see my AWS credentials in workflow logs?**

A: No. GitHub automatically redacts secrets from logs. Even if you accidentally `echo $AWS_SECRET_ACCESS_KEY`, it will show as `***`.

---

## Cleanup / Uninstall

### Complete Removal

To completely remove all resources created by this template:

**Step 1: Destroy Infrastructure**

```bash
cd ~/projects/my-terraform-infrastructure

# Destroy AWS dev environment
cd environments/aws-dev
terraform destroy -auto-approve

# Destroy AWS prod environment
cd ../aws-prod
terraform destroy -auto-approve

# If using Azure
cd ../azure-dev
terraform destroy -auto-approve

cd ../azure-prod
terraform destroy -auto-approve
```

**Step 2: Delete Backend Resources (AWS)**

```bash
# Get your account ID and region
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION="us-east-1"  # Change if you used different region

# Empty and delete S3 bucket
aws s3 rm s3://terraform-state-${ACCOUNT_ID}-${REGION} --recursive
aws s3api delete-bucket \
  --bucket terraform-state-${ACCOUNT_ID}-${REGION} \
  --region ${REGION}

# Delete DynamoDB table
aws dynamodb delete-table \
  --table-name terraform-state-lock \
  --region ${REGION}

# Schedule KMS key deletion (7-30 day waiting period)
KMS_KEY_ID="YOUR_KEY_ID"  # Get from backend.tf
aws kms schedule-key-deletion \
  --key-id ${KMS_KEY_ID} \
  --pending-window-in-days 7 \
  --region ${REGION}
```

**Step 3: Delete Backend Resources (Azure)**

```bash
# Delete the entire resource group (includes storage account and container)
az group delete \
  --name terraform-state-rg \
  --yes \
  --no-wait
```

**Step 4: Remove GitHub Secrets**

```bash
# Remove AWS secrets
gh secret remove AWS_ACCESS_KEY_ID
gh secret remove AWS_SECRET_ACCESS_KEY
gh secret remove AWS_REGION

# Remove Azure secrets
gh secret remove AZURE_CLIENT_ID
gh secret remove AZURE_CLIENT_SECRET
gh secret remove AZURE_SUBSCRIPTION_ID
gh secret remove AZURE_TENANT_ID
```

**Step 5: Delete GitHub Repository (Optional)**

```bash
# ⚠️ WARNING: This permanently deletes the repository!
gh repo delete YOUR_USERNAME/my-terraform-infrastructure --yes
```

**Step 6: Clean Up Local Files**

```bash
# Remove local repository
cd ~
rm -rf ~/projects/my-terraform-infrastructure
```

### Partial Cleanup (Keep Template, Remove Test Resources)

If you just want to clean up test resources but keep the template:

```bash
# Destroy only dev environment
cd ~/projects/my-terraform-infrastructure/environments/aws-dev
terraform destroy

# Keep backend, workflows, and repository for future use
```

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
