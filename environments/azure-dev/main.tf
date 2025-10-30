module "web_server" {
  source = "../../modules/azure/compute"

  # Resource Group
  resource_group_name = "dev-resources-rg"
  location            = "East US"

  # VNet Configuration
  vnet_name   = "dev-vnet"
  vnet_cidr   = "10.10.0.0/16"
  subnet_name = "dev-subnet"
  subnet_cidr = "10.10.1.0/24"

  # VM Configuration
  instance_name  = "dev-web-server"
  vm_size        = "Standard_B1s"  # Low cost for dev
  admin_username = "azureuser"
  private_ip     = "10.10.1.100"
  key_pair_name  = "dev-azure-key"

  # Environment Configuration
  environment      = "dev"
  resource_owner   = "team@example.com"  # UPDATE THIS
  enable_public_ip = true

  # Security Configuration
  allowed_ssh_cidrs = [
    "0.0.0.0/0"  # UPDATE THIS - Restrict to your IP
  ]
  allowed_http_cidrs = [
    "0.0.0.0/0"
  ]
  allowed_icmp_cidrs = [
    "10.0.0.0/8",
    "0.0.0.0/0"
  ]

  # Optional: User data (cloud-init) script
  user_data = file("${path.module}/cloud-init.yaml")
}
