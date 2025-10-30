# Azure Production Environment

This environment deploys production-grade web server infrastructure in Azure.

## Resources Created

- Resource Group
- Virtual Network (10.20.0.0/16)
- Subnet (10.20.1.0/24)
- Network Security Group (Restricted SSH, Public HTTP/HTTPS)
- Linux VM (Standard_D2s_v3, Ubuntu 22.04 LTS)
- Public IP
- Network Interface
- SSH Key Pair

## Usage

### Initialize Terraform

```bash
cd environments/azure-prod
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

### Access the VM

```bash
terraform output -raw ssh_command
```

## Production Considerations

### Security
- SSH access is restricted to internal networks only
- Update `allowed_ssh_cidrs` with your VPN or Azure Bastion CIDR
- SSH key is auto-generated and stored locally
- Consider using Azure Bastion for secure access
- Enable Azure Security Center recommendations

### High Availability
To make this production-ready, consider:
- Azure Availability Zones or Availability Sets
- Virtual Machine Scale Sets (VMSS)
- Azure Load Balancer or Application Gateway
- Azure SQL Database (instead of local storage)
- Azure Monitor and Application Insights

### Monitoring
- Web server logs to `/var/log/web-server.log`
- Set up Azure Monitor alerts for:
  - CPU percentage
  - Disk usage
  - Network traffic
  - Application health

### Backup and Disaster Recovery
- Enable Azure Backup for VMs
- Configure geo-redundant storage for state files
- Document recovery procedures
- Test disaster recovery annually

## Cost Optimization

Current estimated monthly cost (East US):
- VM Standard_D2s_v3: ~$70/month
- Public IP: ~$3.65/month
- Managed Disk: ~$5/month
- Bandwidth: Variable
- **Total**: ~$78-85/month

To optimize costs:
- Use Reserved Instances for ~40% savings
- Enable auto-shutdown for non-24/7 workloads
- Use Azure Advisor recommendations

## Backend Configuration

Before first use:
1. Run `scripts/setup-azure-backend.sh`
2. Update `backend.tf` with actual storage account name
3. Run `terraform init`

## Deployment Workflow

1. Changes made in feature branch
2. Pull request created
3. GitHub Actions runs `terraform plan`
4. Team reviews plan
5. PR merged to main
6. Manual approval required (production environment)
7. GitHub Actions runs `terraform apply`
8. Production deployed

## Emergency Procedures

### Rollback
```bash
git revert HEAD
git push origin main
```

### VM Recovery
```bash
# Stop VM
az vm stop --resource-group prod-resources-rg --name prod-web-server

# Start VM
az vm start --resource-group prod-resources-rg --name prod-web-server

# Restart VM
az vm restart --resource-group prod-resources-rg --name prod-web-server
```

### State Lock Issues
```bash
# Force unlock (use with caution)
terraform force-unlock <LOCK_ID>
```

## Compliance

- Ensure Azure Policy compliance
- Enable Azure Security Center
- Configure diagnostic logs
- Regular security assessments
