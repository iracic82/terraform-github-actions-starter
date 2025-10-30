#!/bin/bash
set -e

# Terraform Azure Backend Setup Script
# This script creates Azure Storage Account and Container for Terraform state management

echo "=========================================="
echo "Terraform Azure Backend Setup"
echo "=========================================="
echo ""

# Configuration - UPDATE THESE VALUES
LOCATION="${AZURE_LOCATION:-eastus}"
RESOURCE_GROUP="terraform-state-rg"
STORAGE_ACCOUNT="tfstate$(openssl rand -hex 4)"  # Must be globally unique
CONTAINER_NAME="tfstate"

echo "Configuration:"
echo "  Azure Location: $LOCATION"
echo "  Resource Group: $RESOURCE_GROUP"
echo "  Storage Account: $STORAGE_ACCOUNT"
echo "  Container: $CONTAINER_NAME"
echo ""

# Check if logged in to Azure
if ! az account show &>/dev/null; then
    echo "❌ Not logged in to Azure. Please run 'az login' first."
    exit 1
fi

SUBSCRIPTION_ID=$(az account show --query id --output tsv)
SUBSCRIPTION_NAME=$(az account show --query name --output tsv)
TENANT_ID=$(az account show --query tenantId --output tsv)

echo "  Subscription: $SUBSCRIPTION_NAME"
echo "  Subscription ID: $SUBSCRIPTION_ID"
echo "  Tenant ID: $TENANT_ID"
echo ""

read -p "Do you want to continue? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

echo ""
echo "Step 1: Creating Resource Group..."
az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --tags Purpose=TerraformState ManagedBy=Script \
    --output none 2>/dev/null || echo "  ⚠️  Resource group might already exist"

echo "  ✅ Resource group created/verified: $RESOURCE_GROUP"

echo ""
echo "Step 2: Creating Storage Account..."
az storage account create \
    --name "$STORAGE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --sku Standard_LRS \
    --kind StorageV2 \
    --encryption-services blob \
    --https-only true \
    --min-tls-version TLS1_2 \
    --allow-blob-public-access false \
    --tags Purpose=TerraformState ManagedBy=Script \
    --output none 2>/dev/null || {
        echo "  ⚠️  Storage account creation failed. It might already exist or name is taken."
        echo "  Trying to use existing storage account..."
        # Try to get existing storage account
        EXISTING_SA=$(az storage account list \
            --resource-group "$RESOURCE_GROUP" \
            --query "[?starts_with(name, 'tfstate')].name" \
            --output tsv | head -n 1)
        if [ -n "$EXISTING_SA" ]; then
            STORAGE_ACCOUNT="$EXISTING_SA"
            echo "  ✅ Using existing storage account: $STORAGE_ACCOUNT"
        else
            echo "  ❌ No existing storage account found. Please check manually."
            exit 1
        fi
    }

echo "  ✅ Storage account created/verified: $STORAGE_ACCOUNT"

echo ""
echo "Step 3: Enabling storage account features..."

# Enable versioning
az storage account blob-service-properties update \
    --account-name "$STORAGE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --enable-versioning true \
    --output none
echo "  ✅ Blob versioning enabled"

# Enable soft delete
az storage account blob-service-properties update \
    --account-name "$STORAGE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --enable-delete-retention true \
    --delete-retention-days 30 \
    --output none
echo "  ✅ Soft delete enabled (30 days)"

echo ""
echo "Step 4: Creating storage container..."

# Get storage account key
STORAGE_KEY=$(az storage account keys list \
    --resource-group "$RESOURCE_GROUP" \
    --account-name "$STORAGE_ACCOUNT" \
    --query '[0].value' \
    --output tsv)

# Create container
az storage container create \
    --name "$CONTAINER_NAME" \
    --account-name "$STORAGE_ACCOUNT" \
    --account-key "$STORAGE_KEY" \
    --output none 2>/dev/null || echo "  ⚠️  Container might already exist"

echo "  ✅ Storage container created/verified: $CONTAINER_NAME"

echo ""
echo "Step 5: Creating Service Principal for GitHub Actions (optional)..."
echo "  This creates a service principal with Contributor access to the subscription."
echo ""
read -p "Do you want to create a service principal? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    SP_NAME="terraform-github-actions-sp"

    # Create service principal
    SP_OUTPUT=$(az ad sp create-for-rbac \
        --name "$SP_NAME" \
        --role Contributor \
        --scopes "/subscriptions/$SUBSCRIPTION_ID" \
        --sdk-auth 2>/dev/null || echo "")

    if [ -n "$SP_OUTPUT" ]; then
        CLIENT_ID=$(echo "$SP_OUTPUT" | jq -r '.clientId')
        CLIENT_SECRET=$(echo "$SP_OUTPUT" | jq -r '.clientSecret')

        echo "  ✅ Service Principal created: $SP_NAME"
        echo ""
        echo "  ⚠️  IMPORTANT: Save these credentials securely!"
        echo "  Client ID: $CLIENT_ID"
        echo "  Client Secret: $CLIENT_SECRET"
    else
        echo "  ⚠️  Service Principal might already exist"
        echo "  You can get existing credentials from Azure Portal or recreate with:"
        echo "  az ad sp create-for-rbac --name \"$SP_NAME\" --role Contributor --scopes \"/subscriptions/$SUBSCRIPTION_ID\""
    fi
fi

echo ""
echo "=========================================="
echo "✅ Azure Backend Setup Complete!"
echo "=========================================="
echo ""
echo "Backend Configuration:"
echo "---"
echo "terraform {"
echo "  backend \"azurerm\" {"
echo "    resource_group_name  = \"$RESOURCE_GROUP\""
echo "    storage_account_name = \"$STORAGE_ACCOUNT\""
echo "    container_name       = \"$CONTAINER_NAME\""
echo "    key                  = \"ENVIRONMENT.terraform.tfstate\"  # Update this per environment"
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
echo "  AZURE_CLIENT_ID=<service-principal-client-id>"
echo "  AZURE_CLIENT_SECRET=<service-principal-client-secret>"
echo "  AZURE_SUBSCRIPTION_ID=$SUBSCRIPTION_ID"
echo "  AZURE_TENANT_ID=$TENANT_ID"
echo ""
echo "For authentication, you can also use:"
echo "  az login"
echo "  az account set --subscription \"$SUBSCRIPTION_ID\""
echo ""
