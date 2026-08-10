output "first_server_public_ip" {
  value = module.k3s_first_server.instances_public_ip
}

output "server_nodes_public_ip" {
  value = flatten([for m in module.k3s_servers : m.instances_public_ip])
}

output "worker_nodes_public_ip" {
  value = flatten([for m in module.k3s_workers : m.instances_public_ip])
}

output "longhorn_url" {
  value = var.longhorn_enabled ? "https://longhorn.${module.k3s_first_server.instances_public_ip}.sslip.io" : null
}

output "rancher_url" {
  value = var.rancher_enabled ? "https://rancher.${module.k3s_first_server.instances_public_ip}.sslip.io/dashboard" : null
}

output "observability_url" {
  value = var.suse_observability_enabled ? "https://observability.${module.k3s_first_server.instances_public_ip}.sslip.io" : null
}

output "neuvector_url" {
  value = var.neuvector_enabled ? "https://neuvector.${module.k3s_first_server.instances_public_ip}.sslip.io" : null
}
