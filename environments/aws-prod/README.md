# AWS Production Environment

This environment deploys production-grade web server infrastructure in AWS.

## Resources Created

- VPC with CIDR 10.1.0.0/24
- Public Subnet
- Internet Gateway
- Security Group (Restricted SSH, Public HTTP/HTTPS)
- EC2 Instance (t3.small, Amazon Linux 2)
- Elastic IP
- SSH Key Pair

## Usage

### Initialize Terraform

```bash
cd environments/aws-prod
terraform init
```

### Plan Changes

```bash
terraform plan
```

### Apply Changes

**IMPORTANT**: Production deployments require approval via GitHub Actions workflow.

For manual deployment:
```bash
terraform apply
```

### Access the Instance

```bash
terraform output -raw ssh_command
```

## Production Considerations

### Security
- SSH access is restricted to internal networks only
- Update `allowed_ssh_cidrs` with your VPN or bastion host CIDR
- SSH key is auto-generated and stored locally
- Consider using AWS Systems Manager Session Manager

### High Availability
To make this production-ready, consider:
- Multiple availability zones
- Auto Scaling Group
- Application Load Balancer
- RDS for database (instead of local storage)
- CloudWatch alarms and monitoring

### Monitoring
- CloudWatch agent is installed via user data
- Web server logs to `/var/log/web-server.log`
- Set up CloudWatch alarms for:
  - CPU utilization
  - Disk space
  - Network traffic

### Backup and Disaster Recovery
- Enable automated EBS snapshots
- Configure S3 versioning for state files
- Document recovery procedures

## Cost Optimization

Current estimated monthly cost (us-east-1):
- EC2 t3.small: ~$15/month
- EBS storage: ~$1/month
- Data transfer: Variable
- **Total**: ~$16-20/month

## Backend Configuration

Before first use:
1. Run `scripts/setup-aws-backend.sh`
2. Update `backend.tf` with actual values
3. Run `terraform init`

## Deployment Workflow

1. Changes made in feature branch
2. Pull request created
3. GitHub Actions runs `terraform plan`
4. Team reviews plan
5. PR merged to main
6. Manual approval required
7. GitHub Actions runs `terraform apply`
8. Production deployed

## Emergency Procedures

### Rollback
```bash
# Revert to previous commit
git revert HEAD
git push origin main
```

### Force Unlock State
```bash
terraform force-unlock <LOCK_ID>
```

### Instance Recovery
```bash
# Stop instance
aws ec2 stop-instances --instance-ids <INSTANCE_ID>

# Start instance
aws ec2 start-instances --instance-ids <INSTANCE_ID>
```
