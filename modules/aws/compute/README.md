# AWS Compute Module

Simple AWS module that creates a complete infrastructure stack:
- VPC with DNS support
- Subnet in first available AZ
- Internet Gateway (optional)
- Route Table with internet route
- Security Group (SSH, HTTP, HTTPS, ICMP)
- EC2 Instance (Amazon Linux 2)
- Elastic IP (optional)
- SSH Key Pair (auto-generated)

## Usage

```hcl
module "aws_web_server" {
  source = "../../modules/aws/compute"

  vpc_name      = "my-vpc"
  vpc_cidr      = "10.0.0.0/24"
  subnet_name   = "my-subnet"
  subnet_cidr   = "10.0.0.0/24"

  instance_name = "web-server"
  instance_type = "t2.micro"
  private_ip    = "10.0.0.100"
  key_pair_name = "my-key"

  environment     = "dev"
  resource_owner  = "your-email@company.com"
  enable_internet = true

  allowed_ssh_cidrs = ["0.0.0.0/0"]
  allowed_http_cidrs = [
    "10.0.0.0/8",
    "72.14.201.91/32"
  ]
}
```

## Features

- **Auto-generated SSH keys**: Private key saved locally with proper permissions
- **Latest Amazon Linux 2**: Automatically uses the latest AMI
- **Security Groups**: Pre-configured for web servers
- **Optional Internet**: Set `enable_internet = false` for private instances
- **User Data Support**: Pass custom initialization scripts

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| vpc_name | Name of the VPC | string | - | yes |
| vpc_cidr | VPC CIDR block | string | - | yes |
| subnet_cidr | Subnet CIDR block | string | - | yes |
| instance_name | EC2 instance name | string | - | yes |
| private_ip | Private IP for instance | string | - | yes |
| key_pair_name | SSH key pair name | string | - | yes |
| environment | Environment (dev/prod) | string | - | yes |
| resource_owner | Resource owner email | string | - | yes |
| instance_type | EC2 instance type | string | t2.micro | no |
| enable_internet | Enable public IP | bool | true | no |
| user_data | Initialization script | string | "" | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | VPC ID |
| instance_id | EC2 instance ID |
| instance_public_ip | Public IP address |
| ssh_command | Command to SSH to instance |
