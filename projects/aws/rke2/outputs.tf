output "first_server_public_ip" {
  value = module.rke2_first_server.instances_public_ip
}

output "server_nodes_public_ip" {
  value = flatten([for m in module.rke2_servers : m.instances_public_ip])
}

output "worker_nodes_public_ip" {
  value = flatten([for m in module.rke2_workers : m.instances_public_ip])
}

output "longhorn_url" {
  value = var.longhorn_enabled ? "https://longhorn.${module.rke2_first_server.instances_public_ip}.sslip.io" : null
}

output "rancher_url" {
  value = var.rancher_enabled ? "https://rancher.${module.rke2_first_server.instances_public_ip}.sslip.io/dashboard" : null
}

output "observability_url" {
  value = var.suse_observability_enabled ? "https://observability.${module.rke2_first_server.instances_public_ip}.sslip.io" : null
}

output "neuvector_url" {
  value = var.neuvector_enabled ? "https://neuvector.${module.rke2_first_server.instances_public_ip}.sslip.io" : null
}
