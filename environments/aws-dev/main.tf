module "web_server" {
  source = "../../modules/aws/compute"

  # VPC Configuration
  vpc_name    = "dev-vpc"
  vpc_cidr    = "10.0.0.0/24"
  subnet_name = "dev-subnet"
  subnet_cidr = "10.0.0.0/24"

  # EC2 Configuration
  instance_name = "dev-web-server"
  instance_type = "t2.micro"
  private_ip    = "10.0.0.100"
  key_pair_name = "dev-key"

  # Environment Configuration
  environment     = "dev"
  resource_owner  = "team@example.com"  # UPDATE THIS
  enable_internet = true

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

  # Optional: User data script
  user_data = file("${path.module}/user-data.sh")
}
