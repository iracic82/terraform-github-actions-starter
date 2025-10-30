terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.20.0"
    }
  }
}

data "aws_availability_zones" "available" {}

# Get latest AWS Linux AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name          = var.vpc_name
    Environment   = var.environment
    ResourceOwner = var.resource_owner
    ManagedBy     = "Terraform"
  }
}

# Create a Subnet
resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name          = var.subnet_name
    Environment   = var.environment
    ResourceOwner = var.resource_owner
    ManagedBy     = "Terraform"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "main" {
  count  = var.enable_internet ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = {
    Name          = "${var.vpc_name}-igw"
    Environment   = var.environment
    ResourceOwner = var.resource_owner
    ManagedBy     = "Terraform"
  }
}

# Create Route Table
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name          = "${var.vpc_name}-rt"
    Environment   = var.environment
    ResourceOwner = var.resource_owner
    ManagedBy     = "Terraform"
  }
}

# Create Route Table Association
resource "aws_route_table_association" "main" {
  route_table_id = aws_route_table.main.id
  subnet_id      = aws_subnet.main.id
}

# Create Default Route to Internet Gateway
resource "aws_route" "internet_access" {
  count                  = var.enable_internet ? 1 : 0
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main[0].id
  route_table_id         = aws_route_table.main.id
}

# Create Security Group
resource "aws_security_group" "main" {
  name   = "${var.vpc_name}-sg"
  vpc_id = aws_vpc.main.id

  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
  }

  # HTTP
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_http_cidrs
  }

  # HTTPS
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_http_cidrs
  }

  # Custom port 5000
  ingress {
    description = "Custom HTTP 5000"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = var.allowed_http_cidrs
  }

  # ICMP
  ingress {
    description = "ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = var.allowed_icmp_cidrs
  }

  # Egress - Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name          = "${var.vpc_name}-sg"
    Environment   = var.environment
    ResourceOwner = var.resource_owner
    ManagedBy     = "Terraform"
  }
}

# Create Network Interface
resource "aws_network_interface" "main" {
  subnet_id       = aws_subnet.main.id
  private_ips     = [var.private_ip]
  security_groups = [aws_security_group.main.id]

  tags = {
    Name          = "${var.instance_name}-nic"
    Environment   = var.environment
    ResourceOwner = var.resource_owner
    ManagedBy     = "Terraform"
  }
}

# Create SSH Key Pair
resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "main" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.main.public_key_openssh

  tags = {
    Environment   = var.environment
    ResourceOwner = var.resource_owner
    ManagedBy     = "Terraform"
  }
}

resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.main.private_key_pem
  filename        = "${path.module}/${var.key_pair_name}.pem"
  file_permission = "0400"
}

# Create EC2 Instance
resource "aws_instance" "main" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.main.key_name

  network_interface {
    network_interface_id = aws_network_interface.main.id
    device_index         = 0
  }

  user_data = var.user_data != "" ? var.user_data : null

  tags = {
    Name          = var.instance_name
    Environment   = var.environment
    ResourceOwner = var.resource_owner
    ManagedBy     = "Terraform"
  }

  depends_on = [aws_key_pair.main]
}

# Create Elastic IP
resource "aws_eip" "main" {
  count                     = var.enable_internet ? 1 : 0
  domain                    = "vpc"
  instance                  = aws_instance.main.id
  associate_with_private_ip = var.private_ip

  tags = {
    Name          = "${var.instance_name}-eip"
    Environment   = var.environment
    ResourceOwner = var.resource_owner
    ManagedBy     = "Terraform"
  }

  depends_on = [aws_internet_gateway.main]
}
