module "web_server" {
  source = "../../modules/aws/compute"

  # VPC Configuration
  vpc_name    = "prod-vpc"
  vpc_cidr    = "10.1.0.0/24"
  subnet_name = "prod-subnet"
  subnet_cidr = "10.1.0.0/24"

  # EC2 Configuration
  instance_name = "prod-web-server"
  instance_type = "t3.small"  # Larger instance for production
  private_ip    = "10.1.0.100"
  key_pair_name = "prod-key"

  # Environment Configuration
  environment     = "prod"
  resource_owner  = "team@example.com"  # UPDATE THIS
  enable_internet = true

  # Security Configuration - MORE RESTRICTIVE for production
  allowed_ssh_cidrs = [
    "10.0.0.0/8"  # UPDATE THIS - Use VPN or bastion host CIDR
  ]
  allowed_http_cidrs = [
    "0.0.0.0/0"  # Public web access
  ]
  allowed_icmp_cidrs = [
    "10.0.0.0/8"  # Only internal networks
  ]

  # Optional: User data script
  user_data = file("${path.module}/user-data.sh")
}
