output "instances_private_ip" {
  description = "AWS EC2 Instance Private IPs."
  value       = aws_instance.vm[0].private_ip
}

output "instances_public_ip" {
  description = "AWS EC2 Instance Public IPs."
  value       = aws_eip.static_ip.public_ip
}

output "aws_security_group" {
  description = "AWS Security Group."
  value       = var.create_network_resources ? aws_security_group.sg[0].id : null
}

output "aws_subnet" {
  description = "AWS Subnet."
  value       = var.create_network_resources ? aws_subnet.public[0].id : null
}
