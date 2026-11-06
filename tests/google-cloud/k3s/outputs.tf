output "instance_public_ip" {
  value = module.eptoolkit_node.instances_public_ip[0]
}

output "kubeconfig_path" {
  value = local_file.kubeconfig_yaml.filename
}

output "longhorn_url" {
  value = var.longhorn_enabled ? "https://longhorn.${module.eptoolkit_node.instances_public_ip[0]}.sslip.io" : null
}

output "rancher_url" {
  value = var.rancher_enabled ? "https://rancher.${module.eptoolkit_node.instances_public_ip[0]}.sslip.io/dashboard" : null
}

output "observability_url" {
  value = var.suse_observability_enabled ? "https://observability.${module.eptoolkit_node.instances_public_ip[0]}.sslip.io" : null
}

output "cluster_node_status" {
  value = ssh_resource.verify_cluster.result
}

output "cluster_pod_status" {
  value = ssh_resource.verify_pods.result
}
