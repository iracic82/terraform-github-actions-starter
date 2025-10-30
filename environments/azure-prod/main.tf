module "web_server" {
  source = "../../modules/azure/compute"

  # Resource Group
  resource_group_name = "prod-resources-rg"
  location            = "East US"

  # VNet Configuration
  vnet_name   = "prod-vnet"
  vnet_cidr   = "10.20.0.0/16"
  subnet_name = "prod-subnet"
  subnet_cidr = "10.20.1.0/24"

  # VM Configuration
  instance_name  = "prod-web-server"
  vm_size        = "Standard_D2s_v3"  # Production-grade VM
  admin_username = "azureuser"
  private_ip     = "10.20.1.100"
  key_pair_name  = "prod-azure-key"

  # Environment Configuration
  environment      = "prod"
  resource_owner   = "team@example.com"  # UPDATE THIS
  enable_public_ip = true

  # Security Configuration - MORE RESTRICTIVE for production
  allowed_ssh_cidrs = [
    "10.0.0.0/8"  # UPDATE THIS - Use VPN or bastion CIDR
  ]
  allowed_http_cidrs = [
    "0.0.0.0/0"  # Public web access
  ]
  allowed_icmp_cidrs = [
    "10.0.0.0/8"  # Only internal networks
  ]

  # Optional: User data (cloud-init) script
  user_data = file("${path.module}/cloud-init.yaml")
}
