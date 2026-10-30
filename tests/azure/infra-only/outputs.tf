output "instance_public_ip" {
  description = "Public IP address of the Azure VM"
  value       = module.eptoolkit_node.instances_public_ip
}

output "kubeconfig_path" {
  description = "Path to the generated kubeconfig file"
  value       = local_file.kubeconfig_yaml.filename
}

output "cluster_nodes_status" {
  description = "Output of the node readiness check via kubectl"
  value       = ssh_resource.verify_cluster.result
}
