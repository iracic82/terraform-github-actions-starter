# Team Member Setup Guide

This guide is for **additional team members** joining an existing Terraform project that was already set up using the [SETUP.md](SETUP.md) guide.

**⚠️ Important:** This guide assumes the project owner has already:
- Created the repository from the template
- Set up the remote backend (S3/Azure Storage)
- Configured GitHub Secrets
- Pushed the initial code

---

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Getting Access](#getting-access)
3. [Local Workstation Setup](#local-workstation-setup)
4. [Clone the Project](#clone-the-project)
5. [Configure Cloud Credentials](#configure-cloud-credentials)
6. [Verify Your Setup](#verify-your-setup)
7. [Your First Change](#your-first-change)

---

## Prerequisites

### Required Tools

Install these tools on your workstation:

```bash
# Check if already installed
git --version        # Git (required)
terraform --version  # Terraform (required)
aws --version        # AWS CLI (if using AWS)
az --version         # Azure CLI (if using Azure)
gh --version         # GitHub CLI (optional but recommended)
code --version       # VS Code (optional but recommended)
```

**Don't have them?** See [SETUP.md - Prerequisites](SETUP.md#prerequisites) for installation instructions.

---

## Getting Access

### Step 1: Get Added to GitHub Repository

Ask the project owner to add you as a collaborator:

**Project Owner needs to:**
1. Go to repository: `https://github.com/OWNER/PROJECT-NAME`
2. Click **Settings** → **Collaborators**
3. Click **Add people**
4. Enter your GitHub username
5. Select role: **Write** (for committing) or **Admin** (for full access)

**You will receive an email invitation** - accept it!

### Step 2: Get Cloud Credentials

Ask the project owner for:

**For AWS:**
- AWS Access Key ID
- AWS Secret Access Key
- AWS Region (e.g., `us-east-1`)
- AWS Account ID (optional, for verification)

**For Azure:**
- Azure Subscription ID
- Azure Tenant ID
- Azure Client ID
- Azure Client Secret
- (Or instructions to create your own service principal)

**⚠️ Security Note:** These credentials are for **local development only**. GitHub Actions uses its own credentials stored in GitHub Secrets.

---

## Local Workstation Setup

### Step 1: Install Required Tools

If you haven't already, install the required tools. See [Prerequisites](#prerequisites) above.

### Step 2: Configure VS Code (Optional)

If using VS Code, install these extensions:
- **HashiCorp Terraform** - Syntax highlighting, IntelliSense
- **GitHub Pull Requests and Issues** - Manage PRs from VS Code
- **GitLens** - Enhanced Git capabilities

---

## Clone the Project

> 📍 **Starting Location:** Any directory (we'll create a projects folder)
> ⏱️ **Estimated Time:** 2 minutes

```bash
# Navigate to your projects directory (create if needed)
mkdir -p ~/projects
cd ~/projects

# Clone the existing repository (NOT the template!)
# Replace OWNER and REPO with actual values
git clone https://github.com/OWNER/my-terraform-infrastructure.git

# Navigate into the directory
cd my-terraform-infrastructure

# Verify you're on the main branch
git branch
# Should show: * main

# Verify the remote
git remote -v
# Should show: origin https://github.com/OWNER/my-terraform-infrastructure.git

# List the contents
ls -la
# Should show: .github/, modules/, environments/, scripts/, docs/
```

**✅ Success Indicator:** You should see the project structure with environments, modules, and workflows.

---

## Configure Cloud Credentials

> 📍 **Starting Location:** Anywhere
> ⏱️ **Estimated Time:** 3 minutes

### For AWS

```bash
# Configure AWS CLI with credentials from project owner
aws configure

# Enter when prompted:
# AWS Access Key ID: AKIA________________
# AWS Secret Access Key: ____________________
# Default region name: us-east-1
# Default output format: json (or press Enter)

# Verify credentials work
aws sts get-caller-identity
```

**✅ Success Indicator:**
```json
{
    "UserId": "AIDA...",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/yourname"
}
```

### For Azure

```bash
# Login to Azure
az login
# This will open a browser - sign in with your account

# List available subscriptions
az account list --output table

# Set the correct subscription (get ID from project owner)
az account set --subscription "SUBSCRIPTION_ID"

# Verify you're in the right subscription
az account show
```

**✅ Success Indicator:** You should see the correct subscription name and ID.

---

## Verify Your Setup

> 📍 **Starting Location:** Project root (`~/projects/my-terraform-infrastructure`)
> ⏱️ **Estimated Time:** 3 minutes

Run these commands to verify everything is working:

### Step 1: Verify Backend Access

```bash
cd ~/projects/my-terraform-infrastructure/environments/aws-dev

# Initialize Terraform (connects to existing backend)
terraform init

# Should see: Successfully configured the backend "s3"!
```

**✅ Success Indicator:**
```
Initializing the backend...
Successfully configured the backend "s3"!

Terraform has been successfully initialized!
```

**❌ If you see errors:**
- `Error: NoSuchBucket` → Check AWS credentials or ask project owner for backend bucket name
- `Error: AccessDenied` → Your AWS user needs permissions for S3, DynamoDB, and KMS
- `Error: Failed to get existing workspaces` → Check AWS region matches backend configuration

### Step 2: Verify Terraform Can Read State

```bash
# Show current state (from S3)
terraform show

# List resources (if any exist)
terraform state list

# Run a plan (read-only operation)
terraform plan
```

**✅ Success Indicator:** Commands run without authentication errors.

### Step 3: Test GitHub Access

```bash
# Authenticate GitHub CLI
gh auth login
# Follow prompts: GitHub.com → HTTPS → Login via browser

# Verify you can access the repository
gh repo view

# Check if you can create branches (permissions test)
gh api /repos/OWNER/REPO/collaborators/YOUR_USERNAME
```

---

## Your First Change

> 📍 **Starting Location:** Project root
> ⏱️ **Estimated Time:** 5 minutes

Let's make a test change to verify your workflow:

### Step 1: Create a Feature Branch

```bash
cd ~/projects/my-terraform-infrastructure

# Create a new branch
git checkout -b test/your-name-setup

# Verify you're on the new branch
git branch
# Should show: * test/your-name-setup
```

### Step 2: Make a Small Change

```bash
# Add a comment to a terraform file (safe change)
echo "  # Added by YOUR_NAME - testing setup" >> environments/aws-dev/main.tf

# Check what changed
git diff environments/aws-dev/main.tf
```

### Step 3: Commit and Push

```bash
# Stage the change
git add environments/aws-dev/main.tf

# Commit with a message
git commit -m "test: verify setup for team member YOUR_NAME"

# Push to GitHub
git push -u origin test/your-name-setup
```

### Step 4: Create a Pull Request

```bash
# Create PR using GitHub CLI
gh pr create \
  --title "Test: Verify setup for YOUR_NAME" \
  --body "Testing that I can create PRs and trigger workflows"

# Or create manually on GitHub
# Go to: https://github.com/OWNER/REPO/pull/new/test/your-name-setup
```

### Step 5: Watch the Workflow

```bash
# Watch workflow run in real-time
gh run watch

# Or check status
gh run list --limit 3
```

**✅ Success Indicator:**
- GitHub Actions workflow runs automatically
- Terraform plan completes successfully
- Plan is posted as a comment on your PR

### Step 6: Clean Up

```bash
# Close the test PR (don't merge)
gh pr close test/your-name-setup

# Switch back to main
git checkout main

# Delete test branch
git branch -D test/your-name-setup

# Delete remote branch
git push origin --delete test/your-name-setup
```

---

## What You DON'T Need to Do

As a team member joining an existing project, you **do NOT** need to:

- ❌ Run backend setup scripts (`setup-aws-backend.sh` or `setup-azure-backend.sh`)
- ❌ Create S3 buckets, DynamoDB tables, or Azure Storage accounts
- ❌ Configure GitHub Secrets (already set by project owner)
- ❌ Set up GitHub Environments (already configured)
- ❌ Create the GitHub repository (it already exists)

**The backend and GitHub Actions are already configured!** You just need local access.

---

## Team Workflow

### Daily Development Workflow

```bash
# 1. Start your day - pull latest changes
cd ~/projects/my-terraform-infrastructure
git checkout main
git pull origin main

# 2. Create a feature branch
git checkout -b feature/add-new-server

# 3. Make your changes
cd environments/aws-dev
# Edit main.tf, add resources, etc.

# 4. Test locally (optional but recommended)
terraform fmt        # Format code
terraform validate   # Validate syntax
terraform plan       # See what will change

# 5. Commit and push
cd ~/projects/my-terraform-infrastructure
git add .
git commit -m "feat: add new web server to dev environment"
git push -u origin feature/add-new-server

# 6. Create PR
gh pr create --title "Add new web server" --body "Adds t2.micro instance for API service"

# 7. Wait for review and approval
# Terraform plan will run automatically and post results

# 8. After PR is merged, pull latest
git checkout main
git pull origin main
```

### Branch Naming Conventions

Use descriptive branch names:
- `feature/add-logging` - New feature
- `fix/security-group-rule` - Bug fix
- `chore/update-modules` - Maintenance
- `test/your-name-setup` - Testing

---

## Common Tasks

### Working on Multiple Environments

```bash
# Switch between environments
cd ~/projects/my-terraform-infrastructure

# Work on dev
cd environments/aws-dev
terraform plan

# Work on prod (be careful!)
cd ../aws-prod
terraform plan  # Read-only, no changes
```

### Checking What Others Changed

```bash
# See recent commits
git log --oneline -10

# See who changed a file
git blame environments/aws-dev/main.tf

# Compare your branch with main
git diff main..HEAD
```

### Pulling Latest Changes

```bash
# Update your local main branch
git checkout main
git pull origin main

# Update your feature branch with latest main
git checkout feature/your-branch
git merge main
# Or use rebase: git rebase main
```

---

## Troubleshooting

### "Permission Denied" When Pushing

**Problem:** `git push` fails with permission error

**Solution:**
1. Verify you were added as a collaborator
2. Check GitHub authentication: `gh auth status`
3. Re-authenticate: `gh auth login`

### "State Lock Already Held"

**Problem:** `terraform plan` says state is locked

**Solution:**
- Someone else (or a workflow) is running terraform
- Wait a few minutes for the lock to release
- Check GitHub Actions to see if a workflow is running
- Don't force-unlock unless absolutely necessary (could cause issues)

### "Backend Bucket Does Not Exist"

**Problem:** `terraform init` fails with bucket not found

**Solution:**
1. Check the backend configuration in `backend.tf`
2. Verify your AWS credentials have access to the bucket
3. Confirm with project owner that backend is set up
4. Check you're in the correct AWS region

### Can't See the Repository

**Problem:** GitHub repository not found

**Solution:**
1. Verify you accepted the collaborator invitation (check email)
2. Check the repository URL is correct
3. Authenticate GitHub CLI: `gh auth login`

---

## Getting Help

### From Your Team

- **Slack/Teams:** Ask in your team channel
- **Project Owner:** Contact the person who invited you
- **Documentation:** Check other docs in `docs/` folder

### External Resources

- **Terraform Docs**: https://www.terraform.io/docs
- **GitHub Docs**: https://docs.github.com/
- **AWS Terraform Provider**: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- **Azure Terraform Provider**: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs

---

## Quick Reference

### Essential Commands

```bash
# Daily workflow
git pull origin main                          # Get latest changes
git checkout -b feature/my-feature            # Create branch
git add .                                     # Stage changes
git commit -m "feat: description"             # Commit
git push -u origin feature/my-feature         # Push
gh pr create --title "Title" --body "Body"    # Create PR

# Terraform workflow
cd environments/aws-dev                       # Navigate to environment
terraform fmt                                 # Format code
terraform validate                            # Validate syntax
terraform plan                                # Preview changes
terraform state list                          # List resources

# Checking status
git status                                    # Git status
git log --oneline -5                          # Recent commits
gh pr list                                    # Your PRs
gh run list                                   # Recent workflows
```

---

## Welcome to the Team! 🎉

You're all set up! You can now:
- ✅ Clone and work on the repository
- ✅ Create branches and pull requests
- ✅ Run terraform locally
- ✅ Trigger GitHub Actions workflows
- ✅ Collaborate with your team

**Next Steps:**
1. Read [ARCHITECTURE.md](ARCHITECTURE.md) to understand the system design
2. Review existing infrastructure in `environments/`
3. Check open PRs to see what the team is working on
4. Ask your team lead about current priorities

Happy coding! 🚀
