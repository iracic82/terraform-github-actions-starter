# Azure Dev Environment

This environment deploys a simple web server infrastructure in Azure for development purposes.

## Resources Created

- Resource Group
- Virtual Network (10.10.0.0/16)
- Subnet (10.10.1.0/24)
- Network Security Group (SSH, HTTP, HTTPS, ICMP)
- Linux VM (Standard_B1s, Ubuntu 22.04 LTS)
- Public IP
- Network Interface
- SSH Key Pair

## Usage

### Initialize Terraform

```bash
cd environments/azure-dev
terraform init
```

### Plan Changes

```bash
terraform plan
```

### Apply Changes

```bash
terraform apply
```

### Access the VM

After apply completes:

```bash
terraform output ssh_command
```

Example:
```bash
ssh -i ../../modules/azure/compute/dev-azure-key.pem azureuser@<PUBLIC_IP>
```

### Destroy Resources

```bash
terraform destroy
```

## Customization

Edit `main.tf` to customize:
- VM size
- VNet CIDR blocks
- Security group rules
- Cloud-init script

## Backend Configuration

Before first use, update `backend.tf` with your storage account details:
1. Run `scripts/setup-azure-backend.sh` to create backend resources
2. Update the storage account name in `backend.tf`
3. Run `terraform init` to initialize the backend

## Azure Authentication

For local development:
```bash
az login
az account set --subscription "<SUBSCRIPTION_ID>"
```

For GitHub Actions, set these secrets:
- `AZURE_CLIENT_ID`
- `AZURE_CLIENT_SECRET`
- `AZURE_SUBSCRIPTION_ID`
- `AZURE_TENANT_ID`

## Security Notes

- Default SSH access is open to 0.0.0.0/0 - **RESTRICT THIS IN PRODUCTION**
- Private SSH key is stored in the modules directory
- Consider using Azure Bastion for secure access

## Cost Optimization

Estimated monthly cost:
- VM Standard_B1s: ~$7.59/month
- Public IP: ~$3.65/month
- Storage: ~$1/month
- **Total**: ~$12-15/month

To reduce costs:
- Stop VM when not in use
- Use Azure Dev/Test pricing if eligible
