output "vpc_id" {
  description = "ID of the VPC"
  value       = module.web_server.vpc_id
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = module.web_server.instance_id
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = module.web_server.instance_public_ip
}

output "ssh_command" {
  description = "Command to SSH into the instance"
  value       = module.web_server.ssh_command
}
