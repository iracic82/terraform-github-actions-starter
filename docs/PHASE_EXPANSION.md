# Phase-Based Expansion Guide

This guide shows you how to expand your Terraform infrastructure from basic GitHub Secrets to advanced OIDC and Vault integration.

## Table of Contents
1. [Overview](#overview)
2. [Phase 1: GitHub Secrets (Current)](#phase-1-github-secrets-current)
3. [Phase 2: OIDC Federation](#phase-2-oidc-federation)
4. [Phase 3: HashiCorp Vault Integration](#phase-3-hashicorp-vault-integration)
5. [Migration Checklist](#migration-checklist)

---

## Overview

### The Three Phases

```
Phase 1: GitHub Secrets (CURRENT)
├─ Simplest setup
├─ Long-lived credentials
└─ Manual rotation required

        ↓ MIGRATE WHEN READY ↓

Phase 2: OIDC Federation (RECOMMENDED)
├─ No long-lived credentials
├─ Auto-rotating tokens
└─ Enhanced security

        ↓ MIGRATE FOR ENTERPRISE ↓

Phase 3: Vault Integration (ENTERPRISE)
├─ Centralized secret management
├─ Dynamic credentials
├─ Full audit trail
└─ Secret rotation automation
```

### When to Migrate

| Phase | Best For | Security Level | Complexity |
|-------|----------|----------------|------------|
| Phase 1 | POC, Learning, Small teams | ⭐⭐ | Low |
| Phase 2 | Production, Medium-Large teams | ⭐⭐⭐⭐ | Medium |
| Phase 3 | Enterprise, Compliance requirements | ⭐⭐⭐⭐⭐ | High |

---

## Phase 1: GitHub Secrets (Current)

### How It Works

```
┌─────────────────────────────────────────────────────┐
│           GitHub Repository Secrets                 │
│  ┌────────────────────────────────────────────────┐ │
│  │ AWS_ACCESS_KEY_ID=AKIAXXXXXXXXXXXXXXXX         │ │
│  │ AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxxxxxxx   │ │
│  │ AZURE_CLIENT_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxx    │ │
│  │ AZURE_CLIENT_SECRET=xxxxxxxxxxxxxxxxxxxxxxxx   │ │
│  └────────────────────────────────────────────────┘ │
└─────────────────┬───────────────────────────────────┘
                  │ (Injected at runtime)
                  ▼
         GitHub Actions Workflow
                  │
                  ├─ Configure AWS Credentials
                  ├─ Configure Azure Credentials
                  └─ Run Terraform
```

### Pros and Cons

**Pros:**
- ✅ Simple to set up (5 minutes)
- ✅ Works immediately
- ✅ Good for learning and POCs
- ✅ No infrastructure dependencies

**Cons:**
- ❌ Long-lived credentials (never expire)
- ❌ Manual rotation required
- ❌ If leaked, valid forever until rotated
- ❌ Credential sprawl across teams
- ❌ No automatic audit trail

### Current Implementation

You are here! Check `.github/workflows/terraform-aws-prod.yml`:

```yaml
- name: Configure AWS Credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-region: ${{ env.AWS_REGION }}
```

---

## Phase 2: OIDC Federation

### What is OIDC?

**OpenID Connect (OIDC)** allows GitHub Actions to authenticate to cloud providers without storing long-lived credentials. Instead, GitHub issues short-lived tokens that cloud providers trust.

### How It Works

```
┌────────────────────────────────────────────────────┐
│        GitHub Actions Workflow Starts              │
└─────────────────┬──────────────────────────────────┘
                  │
                  ▼
┌────────────────────────────────────────────────────┐
│   GitHub Issues OIDC Token (JWT)                   │
│   ┌──────────────────────────────────────────────┐ │
│   │ Token contains:                              │ │
│   │ - Repository: org/repo                       │ │
│   │ - Branch: main                               │ │
│   │ - Workflow: terraform-aws-prod.yml           │ │
│   │ - Expiry: 1 hour                             │ │
│   └──────────────────────────────────────────────┘ │
└─────────────────┬──────────────────────────────────┘
                  │
                  ▼
┌────────────────────────────────────────────────────┐
│   Cloud Provider Validates Token                   │
│   ┌──────────────────────────────────────────────┐ │
│   │ AWS IAM / Azure Entra ID checks:             │ │
│   │ 1. Token signed by GitHub? ✅                │ │
│   │ 2. Repository matches? ✅                    │ │
│   │ 3. Branch matches? ✅                        │ │
│   │ 4. Not expired? ✅                           │ │
│   └──────────────────────────────────────────────┘ │
└─────────────────┬──────────────────────────────────┘
                  │
                  ▼
┌────────────────────────────────────────────────────┐
│   Cloud Provider Issues Temporary Credentials      │
│   - AWS: STS AssumeRoleWithWebIdentity             │
│   - Azure: Federated Token Exchange                │
│   - Valid for: 1 hour                              │
└─────────────────┬──────────────────────────────────┘
                  │
                  ▼
        Terraform Executes with Temp Creds
```

### Benefits

- ✅ **No Long-Lived Credentials**: Tokens expire after 1 hour
- ✅ **Auto-Rotated**: New token for every workflow run
- ✅ **Cannot Be Stolen**: Tokens bound to specific workflow and repo
- ✅ **Principle of Least Privilege**: Different roles per environment
- ✅ **Full Audit Trail**: CloudTrail/Azure Monitor shows OIDC usage

### Migration Steps - AWS OIDC

#### Step 1: Create OIDC Identity Provider in AWS

```bash
# This is usually already configured, check first:
aws iam list-open-id-connect-providers

# If not present, create it:
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
```

#### Step 2: Create IAM Role with OIDC Trust Policy

Create `oidc-trust-policy.json`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:YOUR_ORG/YOUR_REPO:*"
        }
      }
    }
  ]
}
```

Create the role:

```bash
# Create role
aws iam create-role \
  --role-name GitHubActionsTerraformRole \
  --assume-role-policy-document file://oidc-trust-policy.json

# Attach permissions (adjust as needed)
aws iam attach-role-policy \
  --role-name GitHubActionsTerraformRole \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

# Get the role ARN
aws iam get-role \
  --role-name GitHubActionsTerraformRole \
  --query 'Role.Arn' \
  --output text
```

#### Step 3: Update GitHub Workflow

Update `.github/workflows/terraform-aws-prod.yml`:

```yaml
name: "Terraform AWS Prod - Apply"

on:
  push:
    branches:
      - main

permissions:
  id-token: write    # Required for OIDC
  contents: read

jobs:
  terraform-apply:
    name: 'Terraform Apply - AWS Prod'
    runs-on: ubuntu-latest
    environment:
      name: aws-production

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      # NEW: OIDC Authentication (NO SECRETS NEEDED!)
      - name: Configure AWS Credentials via OIDC
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::ACCOUNT_ID:role/GitHubActionsTerraformRole
          aws-region: us-east-1

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Terraform Init
        run: terraform init
        working-directory: ./environments/aws-prod

      - name: Terraform Apply
        run: terraform apply -auto-approve
        working-directory: ./environments/aws-prod
```

#### Step 4: Remove GitHub Secrets

```bash
# Delete the old secrets (they're no longer needed!)
gh secret remove AWS_ACCESS_KEY_ID
gh secret remove AWS_SECRET_ACCESS_KEY
```

### Migration Steps - Azure OIDC

#### Step 1: Create Azure AD Application

```bash
# Create Azure AD app
APP_ID=$(az ad app create \
  --display-name "GitHub Actions Terraform" \
  --query appId \
  --output tsv)

# Create service principal
az ad sp create --id $APP_ID

# Get subscription and tenant IDs
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
TENANT_ID=$(az account show --query tenantId -o tsv)
```

#### Step 2: Create Federated Credential

```bash
# Create federated credential
az ad app federated-credential create \
  --id $APP_ID \
  --parameters '{
    "name": "github-actions-terraform",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:YOUR_ORG/YOUR_REPO:ref:refs/heads/main",
    "description": "GitHub Actions Terraform",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

#### Step 3: Assign Permissions

```bash
# Assign Contributor role to the service principal
az role assignment create \
  --assignee $APP_ID \
  --role Contributor \
  --scope /subscriptions/$SUBSCRIPTION_ID
```

#### Step 4: Update GitHub Workflow

Update `.github/workflows/terraform-azure-prod.yml`:

```yaml
name: "Terraform Azure Prod - Apply"

on:
  push:
    branches:
      - main

permissions:
  id-token: write    # Required for OIDC
  contents: read

jobs:
  terraform-apply:
    name: 'Terraform Apply - Azure Prod'
    runs-on: ubuntu-latest
    environment:
      name: azure-production

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      # NEW: OIDC Authentication (NO CLIENT SECRET!)
      - name: Azure Login via OIDC
        uses: azure/login@v1
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Terraform Init
        run: terraform init
        working-directory: ./environments/azure-prod

      - name: Terraform Apply
        run: terraform apply -auto-approve
        working-directory: ./environments/azure-prod
```

#### Step 5: Update GitHub Secrets

```bash
# Keep these (they're not secrets anymore, just IDs)
gh secret set AZURE_CLIENT_ID --body "$APP_ID"
gh secret set AZURE_TENANT_ID --body "$TENANT_ID"
gh secret set AZURE_SUBSCRIPTION_ID --body "$SUBSCRIPTION_ID"

# DELETE this (no longer needed!)
gh secret remove AZURE_CLIENT_SECRET
```

---

## Phase 3: HashiCorp Vault Integration

### What is Vault?

**HashiCorp Vault** is a centralized secret management platform that provides:
- Dynamic secret generation
- Secret rotation
- Encryption as a service
- Detailed audit logs

### How It Works with Terraform

```
┌────────────────────────────────────────────┐
│     GitHub Actions Workflow Starts         │
└─────────────────┬──────────────────────────┘
                  │
                  ▼
┌────────────────────────────────────────────┐
│  Authenticate to Vault via GitHub OIDC     │
│  ┌──────────────────────────────────────┐  │
│  │ 1. GitHub issues OIDC token          │  │
│  │ 2. Exchange token for Vault token    │  │
│  │ 3. Vault validates GitHub identity   │  │
│  └──────────────────────────────────────┘  │
└─────────────────┬──────────────────────────┘
                  │
                  ▼
┌────────────────────────────────────────────┐
│   Vault Generates Dynamic Cloud Credentials│
│   ┌──────────────────────────────────────┐ │
│   │ AWS: STS temporary credentials       │ │
│   │ Azure: Service Principal with TTL    │ │
│   │ Valid for: 1 hour                    │ │
│   │ Automatically cleaned up after use   │ │
│   └──────────────────────────────────────┘ │
└─────────────────┬──────────────────────────┘
                  │
                  ▼
        Terraform Executes with Dynamic Creds
                  │
                  ▼
┌────────────────────────────────────────────┐
│   After Workflow: Credentials Revoked      │
│   - Vault automatically revokes            │
│   - Credentials no longer valid            │
│   - Full audit trail in Vault             │
└────────────────────────────────────────────┘
```

### Benefits

- ✅ **Dynamic Credentials**: Generated on-demand, revoked after use
- ✅ **Centralized Management**: Single source of truth for all secrets
- ✅ **Automatic Rotation**: Vault rotates secrets automatically
- ✅ **Audit Trail**: Every secret access logged
- ✅ **Encryption as a Service**: Encrypt sensitive Terraform data
- ✅ **Multi-Cloud**: Single Vault instance for AWS, Azure, GCP

### Prerequisites

You need:
- HashiCorp Vault deployed (HCP Vault or self-hosted)
- Vault configured with AWS Secrets Engine
- Vault configured with Azure Secrets Engine
- Vault JWT authentication method configured

### Migration Steps - Vault Setup

#### Step 1: Configure Vault JWT Auth for GitHub

```bash
# Enable JWT auth
vault auth enable jwt

# Configure JWT auth
vault write auth/jwt/config \
  oidc_discovery_url="https://token.actions.githubusercontent.com" \
  bound_issuer="https://token.actions.githubusercontent.com"

# Create role for your repository
vault write auth/jwt/role/github-terraform \
  role_type="jwt" \
  bound_audiences="vault.hashicorp.com" \
  bound_subject="repo:YOUR_ORG/YOUR_REPO:ref:refs/heads/main" \
  user_claim="actor" \
  policies="terraform-policy" \
  ttl="1h"
```

#### Step 2: Configure AWS Secrets Engine

```bash
# Enable AWS secrets engine
vault secrets enable aws

# Configure AWS root credentials (Vault uses these to generate temp creds)
vault write aws/config/root \
  access_key=AKIAXXXXXXXXXXXXXXXX \
  secret_key=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx \
  region=us-east-1

# Create role that generates temporary credentials
vault write aws/roles/terraform-deploy \
  credential_type=sts_assumed_role \
  role_arns=arn:aws:iam::ACCOUNT_ID:role/TerraformDeployRole \
  ttl=1h \
  max_ttl=2h
```

#### Step 3: Configure Azure Secrets Engine

```bash
# Enable Azure secrets engine
vault secrets enable azure

# Configure Azure
vault write azure/config \
  subscription_id=$SUBSCRIPTION_ID \
  tenant_id=$TENANT_ID \
  client_id=$CLIENT_ID \
  client_secret=$CLIENT_SECRET

# Create role
vault write azure/roles/terraform-deploy \
  ttl=1h \
  azure_roles=-<<EOF
    [
      {
        "role_name": "Contributor",
        "scope": "/subscriptions/$SUBSCRIPTION_ID"
      }
    ]
EOF
```

#### Step 4: Create Vault Policy

Create `terraform-policy.hcl`:

```hcl
# Allow reading AWS credentials
path "aws/creds/terraform-deploy" {
  capabilities = ["read"]
}

# Allow reading Azure credentials
path "azure/creds/terraform-deploy" {
  capabilities = ["read"]
}

# Allow reading secrets
path "secret/data/terraform/*" {
  capabilities = ["read"]
}
```

Apply the policy:

```bash
vault policy write terraform-policy terraform-policy.hcl
```

#### Step 5: Update GitHub Workflow

Update `.github/workflows/terraform-aws-prod.yml`:

```yaml
name: "Terraform AWS Prod - Apply"

on:
  push:
    branches:
      - main

permissions:
  id-token: write
  contents: read

env:
  VAULT_ADDR: https://vault.company.com  # Your Vault address

jobs:
  terraform-apply:
    name: 'Terraform Apply - AWS Prod'
    runs-on: ubuntu-latest
    environment:
      name: aws-production

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      # NEW: Authenticate to Vault via OIDC
      - name: Import Secrets from Vault
        uses: hashicorp/vault-action@v2
        with:
          url: ${{ env.VAULT_ADDR }}
          role: github-terraform
          method: jwt
          secrets: |
            aws/creds/terraform-deploy access_key | AWS_ACCESS_KEY_ID ;
            aws/creds/terraform-deploy secret_key | AWS_SECRET_ACCESS_KEY

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ env.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ env.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Terraform Init
        run: terraform init
        working-directory: ./environments/aws-prod

      - name: Terraform Apply
        run: terraform apply -auto-approve
        working-directory: ./environments/aws-prod

      # Credentials are automatically revoked by Vault after workflow
```

---

## Migration Checklist

### Phase 1 → Phase 2 (GitHub Secrets to OIDC)

**AWS:**
- [ ] Create OIDC identity provider in AWS
- [ ] Create IAM role with OIDC trust policy
- [ ] Attach appropriate permissions to role
- [ ] Update GitHub workflow to use OIDC
- [ ] Test in dev environment first
- [ ] Deploy to prod
- [ ] Delete GitHub Secrets (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
- [ ] Revoke old IAM user credentials

**Azure:**
- [ ] Create Azure AD application
- [ ] Create federated credential
- [ ] Assign appropriate role
- [ ] Update GitHub workflow to use OIDC
- [ ] Test in dev environment first
- [ ] Deploy to prod
- [ ] Delete AZURE_CLIENT_SECRET from GitHub Secrets
- [ ] Delete old service principal

### Phase 2 → Phase 3 (OIDC to Vault)

**Prerequisites:**
- [ ] Deploy Vault (HCP or self-hosted)
- [ ] Configure Vault TLS
- [ ] Set up Vault high availability
- [ ] Configure backup and disaster recovery

**Configuration:**
- [ ] Enable and configure JWT auth in Vault
- [ ] Enable AWS secrets engine
- [ ] Enable Azure secrets engine
- [ ] Create Vault policies
- [ ] Create Vault roles
- [ ] Test Vault dynamic credential generation

**Migration:**
- [ ] Update GitHub workflows to use Vault
- [ ] Test in dev environment
- [ ] Deploy to prod
- [ ] Monitor Vault audit logs
- [ ] Set up Vault alerts

**Cleanup:**
- [ ] Remove cloud credentials from workflows
- [ ] Update documentation
- [ ] Train team on Vault usage

---

## Comparison Matrix

| Feature | Phase 1 | Phase 2 | Phase 3 |
|---------|---------|---------|---------|
| **Setup Complexity** | Low | Medium | High |
| **Credential Lifetime** | Forever | 1 hour | 1 hour |
| **Auto-Rotation** | No | Yes | Yes |
| **Audit Trail** | Limited | CloudTrail/Azure | Vault + Cloud |
| **Secret Sprawl** | High | Low | None |
| **Cost** | Free | Free | Vault license |
| **Security Rating** | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Recommended For** | POC | Production | Enterprise |

---

## Recommendations

### For Most Teams: Phase 2 (OIDC)

We recommend **Phase 2 (OIDC)** for most production deployments because:

- ✅ Significantly more secure than static credentials
- ✅ No additional infrastructure to manage
- ✅ Free to use
- ✅ Easy to implement
- ✅ Supported by all major cloud providers

### For Enterprise: Phase 3 (Vault)

Consider **Phase 3 (Vault)** if you:

- Need centralized secret management across multiple teams
- Have compliance requirements for secret rotation
- Manage secrets across many cloud providers
- Need encryption as a service
- Require detailed audit trails

---

## Next Steps

1. **Review your current setup** (Phase 1)
2. **Plan your migration timeline** to Phase 2
3. **Test OIDC in dev environment** before prod
4. **Document your specific implementation**
5. **Train your team** on the new authentication flow

For questions or issues, open a GitHub issue in this repository!
