output "instance_public_ip" {
  value = module.rke2_first_server.instances_public_ip[0]
}

output "kubeconfig_path" {
  value = local_file.kubeconfig_yaml.filename
}

output "cluster_nodes_status" {
  value = ssh_resource.verify_cluster.result
}
