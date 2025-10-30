output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "ID of the subnet"
  value       = aws_subnet.main.id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.main.id
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.main.id
}

output "instance_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.main.private_ip
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = var.enable_internet ? aws_eip.main[0].public_ip : null
}

output "ssh_private_key_path" {
  description = "Path to the SSH private key"
  value       = local_sensitive_file.private_key.filename
  sensitive   = true
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = var.enable_internet ? "ssh -i ${local_sensitive_file.private_key.filename} ec2-user@${aws_eip.main[0].public_ip}" : "Instance has no public IP"
}
