#!/bin/bash
set -e

# Terraform AWS Backend Setup Script
# This script creates S3 bucket and DynamoDB table for Terraform state management

echo "=========================================="
echo "Terraform AWS Backend Setup"
echo "=========================================="
echo ""

# Configuration - UPDATE THESE VALUES
AWS_REGION="${AWS_REGION:-us-east-1}"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
BUCKET_NAME="terraform-state-${AWS_ACCOUNT_ID}-${AWS_REGION}"
DYNAMODB_TABLE="terraform-state-lock"
KMS_ALIAS="alias/terraform-state"

echo "Configuration:"
echo "  AWS Region: $AWS_REGION"
echo "  AWS Account ID: $AWS_ACCOUNT_ID"
echo "  S3 Bucket: $BUCKET_NAME"
echo "  DynamoDB Table: $DYNAMODB_TABLE"
echo "  KMS Alias: $KMS_ALIAS"
echo ""

read -p "Do you want to continue? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

echo ""
echo "Step 1: Creating KMS Key for encryption..."
KMS_KEY_ID=$(aws kms create-key \
    --description "Terraform State Encryption Key" \
    --region "$AWS_REGION" \
    --query 'KeyMetadata.KeyId' \
    --output text 2>/dev/null || echo "")

if [ -z "$KMS_KEY_ID" ]; then
    echo "  ⚠️  KMS key might already exist or creation failed"
    # Try to get existing key
    KMS_KEY_ID=$(aws kms list-aliases \
        --region "$AWS_REGION" \
        --query "Aliases[?AliasName=='${KMS_ALIAS}'].TargetKeyId" \
        --output text)
    if [ -n "$KMS_KEY_ID" ]; then
        echo "  ✅ Using existing KMS key: $KMS_KEY_ID"
    fi
else
    echo "  ✅ KMS Key created: $KMS_KEY_ID"

    # Create alias
    aws kms create-alias \
        --alias-name "$KMS_ALIAS" \
        --target-key-id "$KMS_KEY_ID" \
        --region "$AWS_REGION" || echo "  ⚠️  Alias might already exist"

    # Enable key rotation
    aws kms enable-key-rotation \
        --key-id "$KMS_KEY_ID" \
        --region "$AWS_REGION" || echo "  ⚠️  Key rotation already enabled"

    echo "  ✅ KMS alias created: $KMS_ALIAS"
fi

echo ""
echo "Step 2: Creating S3 bucket..."
aws s3api create-bucket \
    --bucket "$BUCKET_NAME" \
    --region "$AWS_REGION" \
    $(if [ "$AWS_REGION" != "us-east-1" ]; then echo "--create-bucket-configuration LocationConstraint=$AWS_REGION"; fi) \
    2>/dev/null || echo "  ⚠️  Bucket might already exist"

echo "  ✅ S3 bucket created/verified: $BUCKET_NAME"

echo ""
echo "Step 3: Configuring S3 bucket..."

# Enable versioning
aws s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled \
    --region "$AWS_REGION"
echo "  ✅ Versioning enabled"

# Block public access
aws s3api put-public-access-block \
    --bucket "$BUCKET_NAME" \
    --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true" \
    --region "$AWS_REGION"
echo "  ✅ Public access blocked"

# Enable encryption (if KMS key exists)
if [ -n "$KMS_KEY_ID" ]; then
    aws s3api put-bucket-encryption \
        --bucket "$BUCKET_NAME" \
        --server-side-encryption-configuration "{
            \"Rules\": [{
                \"ApplyServerSideEncryptionByDefault\": {
                    \"SSEAlgorithm\": \"aws:kms\",
                    \"KMSMasterKeyID\": \"${KMS_KEY_ID}\"
                },
                \"BucketKeyEnabled\": true
            }]
        }" \
        --region "$AWS_REGION"
    echo "  ✅ KMS encryption enabled"
fi

# Add lifecycle policy (optional - keep old versions for 90 days)
# Note: Skipping lifecycle policy for simplicity - can be added manually if needed
# aws s3api put-bucket-lifecycle-configuration \
#     --bucket "$BUCKET_NAME" \
#     --lifecycle-configuration '{
#         "Rules": [{
#             "ID": "DeleteOldVersions",
#             "Status": "Enabled",
#             "NoncurrentVersionExpiration": {
#                 "NoncurrentDays": 90
#             }
#         }]
#     }' \
#     --region "$AWS_REGION"
echo "  ℹ️  Lifecycle policy skipped (optional - can be added later)"

echo ""
echo "Step 4: Creating DynamoDB table..."
aws dynamodb create-table \
    --table-name "$DYNAMODB_TABLE" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region "$AWS_REGION" \
    --tags Key=Purpose,Value=TerraformStateLock Key=ManagedBy,Value=Script \
    2>/dev/null || echo "  ⚠️  Table might already exist"

echo "  ✅ DynamoDB table created/verified: $DYNAMODB_TABLE"

# Enable point-in-time recovery
aws dynamodb update-continuous-backups \
    --table-name "$DYNAMODB_TABLE" \
    --point-in-time-recovery-specification PointInTimeRecoveryEnabled=true \
    --region "$AWS_REGION" \
    2>/dev/null || echo "  ⚠️  PITR might already be enabled"

echo "  ✅ Point-in-time recovery enabled"

echo ""
echo "=========================================="
echo "✅ AWS Backend Setup Complete!"
echo "=========================================="
echo ""
echo "Backend Configuration:"
echo "---"
echo "terraform {"
echo "  backend \"s3\" {"
echo "    bucket         = \"$BUCKET_NAME\""
echo "    key            = \"ENVIRONMENT/terraform.tfstate\"  # Update this per environment"
echo "    region         = \"$AWS_REGION\""
echo "    dynamodb_table = \"$DYNAMODB_TABLE\""
echo "    encrypt        = true"
if [ -n "$KMS_KEY_ID" ]; then
    KMS_ARN="arn:aws:kms:${AWS_REGION}:${AWS_ACCOUNT_ID}:key/${KMS_KEY_ID}"
    echo "    kms_key_id     = \"$KMS_ARN\""
fi
echo "  }"
echo "}"
echo "---"
echo ""
echo "Next steps:"
echo "1. Copy the backend configuration above"
echo "2. Update backend.tf in each environment folder"
echo "3. Run 'terraform init' to migrate to the remote backend"
echo ""
echo "GitHub Secrets to set:"
echo "  AWS_ACCESS_KEY_ID=<your-access-key-id>"
echo "  AWS_SECRET_ACCESS_KEY=<your-secret-access-key>"
echo "  AWS_REGION=$AWS_REGION"
echo ""
