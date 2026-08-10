output "first_server_public_ip" {
  description = "GCP Compute Engine instance public IP for the first server."
  value       = module.rke2_first_server.instances_public_ip[0]
}

output "server_nodes_public_ip" {
  description = "GCP Compute Engine instance public IPs for additional server nodes."
  value       = flatten([for m in module.rke2_servers : m.instances_public_ip])
}

output "worker_nodes_public_ip" {
  description = "GCP Compute Engine instance public IPs for worker nodes."
  value       = flatten([for m in module.rke2_workers : m.instances_public_ip])
}

output "longhorn_url" {
  description = "Longhorn web UI URL."
  value       = var.longhorn_enabled ? "https://longhorn.${module.rke2_first_server.instances_public_ip[0]}.sslip.io" : null
}

output "rancher_url" {
  description = "Rancher Dashboard web UI URL."
  value       = var.rancher_enabled ? "https://rancher.${module.rke2_first_server.instances_public_ip[0]}.sslip.io/dashboard" : null
}

output "observability_url" {
  description = "SUSE Observability web UI URL."
  value       = var.suse_observability_enabled ? "https://observability.${module.rke2_first_server.instances_public_ip[0]}.sslip.io" : null
}

output "neuvector_url" {
  description = "NeuVector web UI URL."
  value       = var.neuvector_enabled ? "https://neuvector.${module.rke2_first_server.instances_public_ip[0]}.sslip.io" : null
}
