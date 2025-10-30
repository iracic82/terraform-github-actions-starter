# Azure Compute Module

Simple Azure module that creates a complete infrastructure stack:
- Resource Group
- Virtual Network (VNet)
- Subnet
- Network Security Group (SSH, HTTP, HTTPS, ICMP)
- Linux Virtual Machine (Ubuntu 22.04 LTS)
- Public IP (optional)
- Network Interface
- SSH Key Pair (auto-generated)

## Usage

```hcl
module "azure_web_server" {
  source = "../../modules/azure/compute"

  resource_group_name = "my-resource-group"
  location            = "East US"

  vnet_name    = "my-vnet"
  vnet_cidr    = "10.0.0.0/16"
  subnet_name  = "my-subnet"
  subnet_cidr  = "10.0.1.0/24"

  instance_name  = "web-server"
  vm_size        = "Standard_B1s"
  admin_username = "azureuser"
  private_ip     = "10.0.1.100"
  key_pair_name  = "my-key"

  environment      = "dev"
  resource_owner   = "your-email@company.com"
  enable_public_ip = true

  allowed_ssh_cidrs = ["0.0.0.0/0"]
  allowed_http_cidrs = [
    "10.0.0.0/8",
    "72.14.201.91/32"
  ]
}
```

## Features

- **Auto-generated SSH keys**: Private key saved locally with proper permissions
- **Latest Ubuntu LTS**: Automatically uses Ubuntu 22.04 LTS
- **Network Security Groups**: Pre-configured for web servers
- **Optional Public IP**: Set `enable_public_ip = false` for private VMs
- **User Data Support**: Pass cloud-init scripts

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| resource_group_name | Resource group name | string | - | yes |
| location | Azure region | string | - | yes |
| vnet_name | VNet name | string | - | yes |
| vnet_cidr | VNet CIDR block | string | - | yes |
| subnet_cidr | Subnet CIDR block | string | - | yes |
| instance_name | VM name | string | - | yes |
| private_ip | Private IP for VM | string | - | yes |
| key_pair_name | SSH key pair name | string | - | yes |
| environment | Environment (dev/prod) | string | - | yes |
| resource_owner | Resource owner email | string | - | yes |
| vm_size | VM size | string | Standard_B1s | no |
| admin_username | Admin username | string | azureuser | no |
| enable_public_ip | Enable public IP | bool | true | no |
| user_data | Cloud-init script | string | "" | no |

## Outputs

| Name | Description |
|------|-------------|
| resource_group_id | Resource group ID |
| vnet_id | VNet ID |
| vm_id | VM ID |
| vm_public_ip | Public IP address |
| ssh_command | Command to SSH to VM |
