output "instances_private_ip" {
  description = "GCP Compute Engine Instance Private IPs."
  value       = google_compute_instance.vm[*].network_interface[0].network_ip
}

output "instances_public_ip" {
  description = "GCP Compute Engine Instance Public IPs."
  value       = google_compute_instance.vm[*].network_interface[0].access_config[0].nat_ip
}

output "gcp_vpc" {
  description = "GCP VPC Network ID/Name."
  value       = var.create_network_resources ? google_compute_network.vpc[0].id : var.vpc_id
}

output "gcp_subnet" {
  description = "GCP Subnet ID/Name."
  value       = var.create_network_resources ? google_compute_subnetwork.subnet[0].id : var.subnet_id
}
