# AWS Dev Environment

This environment deploys a simple web server infrastructure in AWS for development purposes.

## Resources Created

- VPC with CIDR 10.0.0.0/24
- Public Subnet
- Internet Gateway
- Security Group (SSH, HTTP, HTTPS, ICMP)
- EC2 Instance (t2.micro, Amazon Linux 2)
- Elastic IP
- SSH Key Pair

## Usage

### Initialize Terraform

```bash
cd environments/aws-dev
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

### Access the Instance

After apply completes, Terraform will output the SSH command:

```bash
terraform output ssh_command
```

Example:
```bash
ssh -i ../../modules/aws/compute/dev-key.pem ec2-user@<PUBLIC_IP>
```

### Destroy Resources

```bash
terraform destroy
```

## Customization

Edit `main.tf` to customize:
- Instance type
- VPC CIDR blocks
- Security group rules
- User data script

## Backend Configuration

Before first use, update `backend.tf` with your S3 bucket details:
1. Run `scripts/setup-aws-backend.sh` to create backend resources
2. Update the bucket name, region, and KMS key ID in `backend.tf`
3. Run `terraform init` to initialize the backend

## Security Notes

- Default SSH access is open to 0.0.0.0/0 - **RESTRICT THIS IN PRODUCTION**
- Private SSH key is stored in the modules directory
- Consider using AWS Systems Manager Session Manager instead of SSH
