output "image_id" {
  description = "The ID of the custom OS image used for all RKE2 cluster EC2 instances."
  value       = aws_ami.opensuse_ami.id
}
