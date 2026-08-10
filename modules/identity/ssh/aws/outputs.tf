output "ssh_private_key" {
  description = "Private SSH key generated for the infrastructure."
  value       = tls_private_key.ssh.private_key_openssh
  sensitive   = true
}

output "ssh_public_key" {
  description = "Public SSH key generated for the infrastructure."
  value       = tls_private_key.ssh.public_key_openssh
}

output "ssh_key_name" {
  description = "AWS SSH key Name generated for the infrastructure."
  value       = aws_key_pair.generated.key_name
}

output "private_ssh_key_path" {
  description = "Path of the generated SSH private key."
  value       = local.private_ssh_key_path
}

output "public_ssh_key_path" {
  description = "Path of the generated SSH public key."
  value       = local.public_ssh_key_path
}
