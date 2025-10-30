# Architecture Overview

This document explains the system architecture, design decisions, and how all components work together.

## Table of Contents
1. [High-Level Architecture](#high-level-architecture)
2. [Remote State Architecture](#remote-state-architecture)
3. [GitHub Actions CI/CD Pipeline](#github-actions-cicd-pipeline)
4. [Module Architecture](#module-architecture)
5. [Security Model](#security-model)
6. [State Locking Mechanism](#state-locking-mechanism)
7. [Environment Isolation](#environment-isolation)

---

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                          Developer                              │
│                            (VS Code)                            │
└────────────────────┬───────────────────────┬────────────────────┘
                     │                       │
                     ▼                       ▼
        ┌─────────────────────┐  ┌─────────────────────┐
        │   Feature Branch    │  │    Pull Request     │
        │    (git push)       │  │   (terraform plan)  │
        └──────────┬──────────┘  └──────────┬──────────┘
                   │                        │
                   ▼                        ▼
            ┌──────────────────────────────────────────┐
            │         GitHub Repository                │
            │  ┌────────────────────────────────────┐  │
            │  │     GitHub Actions Workflows       │  │
            │  ├────────────────────────────────────┤  │
            │  │  • terraform-aws-dev.yml  (Plan)   │  │
            │  │  • terraform-aws-prod.yml (Apply)  │  │
            │  │  • terraform-azure-dev.yml (Plan)  │  │
            │  │  • terraform-azure-prod.yml(Apply) │  │
            │  └────────────────────────────────────┘  │
            └──────────┬──────────────┬────────────────┘
                       │              │
           ┌───────────┘              └───────────┐
           ▼                                      ▼
    ┌──────────────┐                      ┌──────────────┐
    │   AWS Cloud  │                      │ Azure Cloud  │
    ├──────────────┤                      ├──────────────┤
    │ S3 + DynamoDB│                      │   Storage    │
    │  (State)     │                      │   (State)    │
    ├──────────────┤                      ├──────────────┤
    │ VPC, EC2, SG │                      │ VNet, VM,NSG │
    │ (Resources)  │                      │ (Resources)  │
    └──────────────┘                      └──────────────┘
```

---

## Remote State Architecture

### Why Remote State is Critical

**Without Remote State:**
- ❌ State files stored locally on developer machines
- ❌ Team members overwrite each other's changes
- ❌ No backup or version history
- ❌ Secrets visible in plain text on disk
- ❌ No locking = concurrent modifications = corruption

**With Remote State:**
- ✅ State stored centrally in cloud storage
- ✅ Team collaboration with automatic locking
- ✅ Version history and rollback capability
- ✅ Encryption at rest
- ✅ Built-in backup and disaster recovery

### Two-Backend Architecture Explained

This project uses **TWO separate remote state backends**:

```
Project Root
│
├── AWS Environments ────────────► AWS S3 Backend
│   ├── aws-dev/                   │
│   │   └── backend.tf ────────────┤
│   │       bucket: terraform-state-xxx
│   │       key: aws-dev/terraform.tfstate
│   │       dynamodb_table: terraform-state-lock
│   │
│   └── aws-prod/                  │
│       └── backend.tf ────────────┤
│           bucket: terraform-state-xxx
│           key: aws-prod/terraform.tfstate
│           dynamodb_table: terraform-state-lock
│
└── Azure Environments ──────────► Azure Storage Backend
    ├── azure-dev/                 │
    │   └── backend.tf ────────────┤
    │       storage_account: tfstateXXXX
    │       container: tfstate
    │       key: azure-dev.terraform.tfstate
    │
    └── azure-prod/                │
        └── backend.tf ────────────┤
            storage_account: tfstateXXXX
            container: tfstate
            key: azure-prod.terraform.tfstate
```

### Why NOT a Single Unified Backend?

Many people ask: "Why not store all state in one place (e.g., all in S3)?"

#### Answer: Security, Performance, and Compliance

**1. Security Isolation**

```
❌ Single Backend (All in S3)
┌─────────────────────────────────────┐
│        AWS S3 Bucket                │
│  ┌──────────────────────────────┐   │
│  │ aws-dev.tfstate              │   │
│  │ aws-prod.tfstate             │   │
│  │ azure-dev.tfstate            │   │ ← Azure creds needed in S3!
│  │ azure-prod.tfstate           │   │ ← Security risk!
│  └──────────────────────────────┘   │
└─────────────────────────────────────┘
   ⚠️ Problem: Azure credentials must access S3
   ⚠️ Problem: AWS credentials can see Azure state
   ⚠️ Problem: Single point of failure


✅ Dual Backend (Cloud-Native)
┌────────────────────┐    ┌────────────────────┐
│   AWS S3 Bucket    │    │  Azure Storage     │
│  ┌──────────────┐  │    │  ┌──────────────┐  │
│  │aws-dev.tfstate│  │    │  │azure-dev.tf│  │
│  │aws-prod.tfstat│  │    │  │azure-prod.t│  │
│  └──────────────┘  │    │  └──────────────┘  │
└────────────────────┘    └────────────────────┘
   ✅ AWS creds only access AWS
   ✅ Azure creds only access Azure
   ✅ Blast radius contained
```

**2. Performance & Latency**

- **Same-Cloud Storage**: Terraform running in AWS GitHub runner → S3 = fast
- **Cross-Cloud Storage**: Terraform running in AWS → Azure Storage = slow + egress costs

**3. Compliance & Governance**

Many organizations require:
- "AWS data stays in AWS" (data residency)
- "Azure data stays in Azure" (compliance)
- Separate audit trails per cloud (CloudTrail vs Azure Monitor)

**4. Cost Optimization**

- **No Cross-Cloud Egress**: AWS → S3 = free, AWS → Azure = $$$
- **Native Storage Pricing**: S3 is cheaper than Azure for AWS, vice versa

**5. Native Features**

| Feature | AWS Backend | Azure Backend |
|---------|-------------|---------------|
| Encryption | AWS KMS | Azure Storage Service Encryption |
| Locking | DynamoDB | Azure Blob Lease |
| Versioning | S3 Versioning | Blob Versioning |
| Audit | CloudTrail | Azure Monitor |
| DR | Cross-Region Replication | Geo-Redundant Storage |

Using each cloud's native backend gives you the best features for that cloud.

### AWS Backend Deep Dive

#### Components

```
AWS Backend Architecture
┌──────────────────────────────────────────────────┐
│  S3 Bucket: terraform-state-<account>-<region>   │
│  ┌────────────────────────────────────────────┐  │
│  │  aws-dev/terraform.tfstate   (current)     │  │
│  │  aws-dev/terraform.tfstate   (version 1)   │  │
│  │  aws-dev/terraform.tfstate   (version 2)   │  │
│  │  aws-prod/terraform.tfstate  (current)     │  │
│  │  aws-prod/terraform.tfstate  (version 1)   │  │
│  └────────────────────────────────────────────┘  │
│                                                   │
│  Encryption: AWS KMS                              │
│  Versioning: Enabled (90 day retention)           │
│  Public Access: Blocked                           │
└──────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────┐
│  DynamoDB Table: terraform-state-lock             │
│  ┌────────────────────────────────────────────┐  │
│  │ LockID (Hash Key)         │ Info           │  │
│  ├───────────────────────────┼────────────────┤  │
│  │ terraform-state-xxx/      │ Who: GitHub    │  │
│  │   aws-dev/terraform.tfstate│ When: 2024... │  │
│  └────────────────────────────────────────────┘  │
│                                                   │
│  Purpose: Prevent concurrent Terraform runs       │
│  Billing: Pay-per-request                         │
└──────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────┐
│  KMS Key: alias/terraform-state                   │
│  ┌────────────────────────────────────────────┐  │
│  │ Encrypt state files at rest                │  │
│  │ Automatic key rotation enabled              │  │
│  └────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────┘
```

#### State Lifecycle

```
1. terraform plan/apply starts
   ↓
2. Acquire lock in DynamoDB
   - Write LockID with metadata
   - If lock exists → wait or fail
   ↓
3. Download state from S3
   - Decrypt using KMS
   - Load into memory
   ↓
4. Perform terraform operation
   - Plan changes
   - Apply changes
   ↓
5. Upload new state to S3
   - Encrypt using KMS
   - S3 creates new version
   ↓
6. Release lock in DynamoDB
   - Delete LockID entry
```

### Azure Backend Deep Dive

#### Components

```
Azure Backend Architecture
┌──────────────────────────────────────────────────┐
│  Storage Account: tfstate<random>                │
│  ┌────────────────────────────────────────────┐  │
│  │  Container: tfstate                        │  │
│  │  ┌──────────────────────────────────────┐  │  │
│  │  │ azure-dev.terraform.tfstate          │  │  │
│  │  │   - Current version                  │  │  │
│  │  │   - Version 1 (snapshot)             │  │  │
│  │  │   - Version 2 (snapshot)             │  │  │
│  │  │                                      │  │  │
│  │  │ azure-prod.terraform.tfstate         │  │  │
│  │  │   - Current version                  │  │  │
│  │  │   - Version 1 (snapshot)             │  │  │
│  │  └──────────────────────────────────────┘  │  │
│  └────────────────────────────────────────────┘  │
│                                                   │
│  Encryption: Azure SSE (automatic)                │
│  Versioning: Enabled                              │
│  Soft Delete: 30 days                             │
│  Public Access: Disabled                          │
└──────────────────────────────────────────────────┘

Built-in Locking: Azure Blob Lease
┌──────────────────────────────────────────────────┐
│  When Terraform runs:                             │
│  1. Acquire exclusive lease on state blob        │
│  2. Lease duration: 60 seconds (auto-renewed)    │
│  3. If lease exists → operation blocked          │
│  4. After operation → release lease              │
└──────────────────────────────────────────────────┘
```

#### State Lifecycle

```
1. terraform plan/apply starts
   ↓
2. Acquire blob lease (built-in locking)
   - Request exclusive lease on state blob
   - If leased → wait or fail
   ↓
3. Download state from Azure Storage
   - Auto-decrypt (SSE)
   - Load into memory
   ↓
4. Perform terraform operation
   - Plan changes
   - Apply changes
   ↓
5. Upload new state to Azure Storage
   - Auto-encrypt (SSE)
   - New version created
   ↓
6. Release blob lease
   - Lease automatically released
```

### Comparison: AWS vs Azure Backend

| Feature | AWS S3 + DynamoDB | Azure Storage |
|---------|-------------------|---------------|
| **State Storage** | S3 Bucket | Blob Storage |
| **Locking Mechanism** | DynamoDB Table (separate) | Blob Lease (built-in) |
| **Encryption** | KMS (customer-managed) | SSE (Microsoft-managed) |
| **Versioning** | S3 Versioning | Blob Versioning |
| **Soft Delete** | Via versioning | 30-day soft delete |
| **Access Control** | IAM Policies | RBAC + SAS tokens |
| **Audit Logging** | CloudTrail | Azure Monitor |
| **Cost** | S3 + DynamoDB + KMS | Storage Account only |
| **Setup Complexity** | 3 resources | 1 resource |

---

## GitHub Actions CI/CD Pipeline

### Workflow Architecture

```
Pull Request Created
        │
        ▼
┌───────────────────────────┐
│  terraform-aws-dev.yml    │  Triggered by PR
│  terraform-azure-dev.yml  │  on matching paths
└───────────┬───────────────┘
            │
            ├─ Checkout code
            ├─ Configure cloud credentials (GitHub Secrets)
            ├─ Setup Terraform
            ├─ terraform init (connect to backend)
            ├─ terraform validate
            ├─ terraform plan
            └─ Post plan as PR comment
                    │
                    ▼
            Team Reviews Plan
                    │
                    ▼
            PR Merged to main
                    │
                    ▼
┌───────────────────────────┐
│  terraform-aws-prod.yml   │  Triggered by push
│  terraform-azure-prod.yml │  to main branch
└───────────┬───────────────┘
            │
            ├─ Checkout code
            ├─ Configure cloud credentials
            ├─ Setup Terraform
            ├─ terraform init
            ├─ terraform plan -out=tfplan
            │
            ▼
    ⏸️  Wait for Manual Approval
       (GitHub Environment Protection)
            │
            ▼
       Approval Granted
            │
            ├─ terraform apply tfplan
            ├─ Upload plan artifact
            └─ Success ✅
```

### Workflow Triggers

| Workflow | Trigger | Action | Approval |
|----------|---------|--------|----------|
| `terraform-aws-dev.yml` | PR with aws-dev changes | Plan | None |
| `terraform-azure-dev.yml` | PR with azure-dev changes | Plan | None |
| `terraform-aws-prod.yml` | Push to main (aws-prod changes) | Apply | Required |
| `terraform-azure-prod.yml` | Push to main (azure-prod changes) | Apply | Required |

### Security: GitHub Secrets Flow

```
GitHub Secrets (Encrypted)
    ┌──────────────────────────┐
    │ AWS_ACCESS_KEY_ID        │
    │ AWS_SECRET_ACCESS_KEY    │
    │ AWS_REGION               │
    └──────────┬───────────────┘
               │ (Injected at runtime)
               ▼
    GitHub Actions Runner
    ┌──────────────────────────┐
    │ Environment Variables:   │
    │ - AWS_ACCESS_KEY_ID      │
    │ - AWS_SECRET_ACCESS_KEY  │
    │ - AWS_REGION             │
    └──────────┬───────────────┘
               │ (Used by)
               ▼
    aws-actions/configure-aws-credentials@v4
               │
               ▼
    Terraform Execution
    ┌──────────────────────────┐
    │ terraform init           │
    │ terraform plan           │
    │ terraform apply          │
    └──────────────────────────┘

Note: Secrets never logged, never exposed in outputs
```

---

## Module Architecture

### Module Structure

```
modules/
├── aws/
│   └── compute/              ← Reusable AWS module
│       ├── main.tf           ← Resource definitions
│       ├── variables.tf      ← Input variables
│       ├── outputs.tf        ← Output values
│       └── README.md         ← Module documentation
│
└── azure/
    └── compute/              ← Reusable Azure module
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        └── README.md
```

### Why Custom Modules?

**Benefits:**
- **Consistency**: Same pattern for dev and prod
- **Reusability**: DRY principle
- **Standardization**: Enforce organizational standards
- **Simplified Maintenance**: Fix in one place

### Module Usage Pattern

```hcl
# Environment configuration (e.g., environments/aws-dev/main.tf)
module "web_server" {
  source = "../../modules/aws/compute"

  # Module inputs
  vpc_name     = "dev-vpc"
  vpc_cidr     = "10.0.0.0/24"
  instance_name = "dev-web-server"
  environment   = "dev"

  # ... more inputs
}

# Outputs from module
output "instance_ip" {
  value = module.web_server.instance_public_ip
}
```

---

## Security Model

### Phase 1: GitHub Secrets (Current)

```
GitHub Secrets (Long-lived credentials)
    ↓
GitHub Actions Workflow
    ↓
Cloud Provider Authentication
    ↓
Terraform Execution
```

**Pros:**
- ✅ Simple to set up
- ✅ Works immediately
- ✅ Good for getting started

**Cons:**
- ⚠️ Long-lived credentials
- ⚠️ Must rotate manually
- ⚠️ If leaked, valid until rotated

### Phase 2: OIDC (Recommended - Future)

```
GitHub Actions Workflow
    ↓
GitHub OIDC Token (short-lived, auto-generated)
    ↓
Cloud Provider OIDC Trust Relationship
    ↓
Temporary Credentials (1 hour TTL)
    ↓
Terraform Execution
```

**Pros:**
- ✅ No long-lived credentials
- ✅ Auto-rotated every run
- ✅ Cannot be leaked
- ✅ Principle of least privilege

See [PHASE_EXPANSION.md](PHASE_EXPANSION.md) for migration guide.

---

## State Locking Mechanism

### How State Locking Prevents Corruption

**Without Locking:**
```
Time  Developer A          Developer B          State File
────────────────────────────────────────────────────────────
10:00 terraform apply      -                    Version 1
10:01 Reading state...     terraform apply      Version 1
10:02 Modifying...         Reading state...     Version 1
10:03 Writing state...     Modifying...         Version 2 (A's changes)
10:04 Done ✅              Writing state...     Version 3 (B overwrites A!)
10:05 -                    Done ✅              ⚠️ A's changes LOST!
```

**With Locking:**
```
Time  Developer A          Developer B          Lock Status
────────────────────────────────────────────────────────────
10:00 terraform apply      -                    Acquired by A
10:01 Executing...         terraform apply      Locked (waiting...)
10:02 Executing...         ⏸️ Waiting...        Locked by A
10:03 Done, release lock   ⏸️ Waiting...        Released
10:04 -                    Acquired lock!       Acquired by B
10:05 -                    Executing...         Locked by B
10:06 -                    Done ✅              Released
```

### Lock Information

**AWS DynamoDB Lock Entry:**
```json
{
  "LockID": "terraform-state-xxx/aws-dev/terraform.tfstate",
  "Info": {
    "ID": "5e3a1c2f-...",
    "Operation": "OperationTypeApply",
    "Who": "github-actions@runner",
    "Version": "1.6.0",
    "Created": "2024-01-15T10:30:00Z",
    "Path": "aws-dev/terraform.tfstate"
  }
}
```

---

## Environment Isolation

### Complete Separation

```
Each environment is completely isolated:

aws-dev/
├── Own state file: s3://bucket/aws-dev/terraform.tfstate
├── Own VPC: 10.0.0.0/24
├── Own EC2 instance: dev-web-server
├── Own security group
└── Own SSH key

aws-prod/
├── Own state file: s3://bucket/aws-prod/terraform.tfstate
├── Own VPC: 10.1.0.0/24
├── Own EC2 instance: prod-web-server
├── Own security group
└── Own SSH key
```

**Benefits:**
- Changes in dev don't affect prod
- Can destroy dev without touching prod
- Different configurations per environment
- Independent state locking

---

## Disaster Recovery

### State File Recovery

**AWS S3 Versioning:**
```bash
# List all versions
aws s3api list-object-versions \
  --bucket terraform-state-xxx \
  --prefix aws-prod/terraform.tfstate

# Restore specific version
aws s3api get-object \
  --bucket terraform-state-xxx \
  --key aws-prod/terraform.tfstate \
  --version-id <VERSION_ID> \
  recovered-state.tfstate
```

**Azure Blob Versioning:**
```bash
# List versions
az storage blob list \
  --container-name tfstate \
  --account-name tfstateXXX \
  --include v

# Download specific version
az storage blob download \
  --container-name tfstate \
  --name azure-prod.terraform.tfstate \
  --version-id <VERSION_ID> \
  --file recovered-state.tfstate
```

---

## Cost Estimation

### AWS Backend Costs (us-east-1)

| Resource | Usage | Monthly Cost |
|----------|-------|--------------|
| S3 Storage | 1 GB | $0.023 |
| S3 Requests | 1000 | $0.005 |
| DynamoDB | Pay-per-request | ~$0.25 |
| KMS | 1 key | $1.00 |
| **Total** | | **~$1.30/month** |

### Azure Backend Costs (East US)

| Resource | Usage | Monthly Cost |
|----------|-------|--------------|
| Storage Account | 1 GB | $0.018 |
| Transactions | 1000 | $0.004 |
| **Total** | | **~$0.02/month** |

---

## Summary

This architecture provides:

✅ **Secure** - Encrypted state, separated backends, no cross-cloud access
✅ **Scalable** - Supports unlimited environments
✅ **Reliable** - State locking, versioning, backups
✅ **Cost-Effective** - Minimal backend costs
✅ **Collaborative** - Team can work together safely
✅ **Auditable** - CloudTrail and Azure Monitor logs
✅ **Disaster-Ready** - Version history and recovery procedures

The two-backend approach is industry best practice for multi-cloud deployments!
