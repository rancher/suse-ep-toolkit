resource "random_string" "rke2_token" {
  length  = 32
  special = false
}

data "http" "my_public_ip_address" {
  url = "https://ipv4.icanhazip.com/"
}

locals {
  region                     = "nyc3"
  ssh_private_key_path       = "${path.cwd}/${var.prefix}-ssh_private_key.pem"
  ssh_public_key_path        = "${path.cwd}/${var.prefix}-ssh_public_key.pem"
  ssh_username               = "opensuse"
  kubeconfig_file            = "${path.cwd}/${var.prefix}_kubeconfig.yml"
  volume_device              = "/dev/sda"
  instance_type              = var.instance_type
  rke2_token                 = random_string.rke2_token.result
  current_public_ip_cidr     = "${chomp(data.http.my_public_ip_address.response_body)}/32"
  public_ip_source_addresses = length(var.public_ip_source_addresses) > 0 ? var.public_ip_source_addresses : [local.current_public_ip_cidr]
}

module "identity" {
  source = "../../../modules/identity/ssh/digitalocean"
  prefix = var.prefix
}

data "local_file" "ssh_private_key" {
  depends_on = [module.rke2_first_server]
  filename   = local.ssh_private_key_path
}

module "os_image" {
  source = "../../../modules/custom-os-image/digitalocean"
  prefix = var.prefix
  region = local.region
}

module "rke2_first" {
  source                = "../../../modules/distribution/rke2"
  node_role             = "server"
  rke2_token            = local.rke2_token
  rke2_version          = var.rke2_version
  rke2_ingress          = var.rke2_ingress
  volume_device         = local.volume_device
  is_gpu_instance       = false
  install_prerequisites = false
}

module "rke2_first_server" {
  source                     = "../../../modules/infrastructure/digitalocean/droplet"
  prefix                     = "${var.prefix}-server-1"
  region                     = local.region
  ssh_key_id                 = module.identity.ssh_key_id
  ssh_private_key_content    = module.identity.ssh_private_key
  instance_type              = local.instance_type
  data_disk_size             = var.data_disk_size
  public_ip_source_addresses = local.public_ip_source_addresses
  image_id                   = module.os_image.image_id
  instance_count             = 1
  user_data                  = module.rke2_first.user_data
}

resource "ssh_resource" "retrieve_kubeconfig" {
  depends_on = [module.rke2_first_server]
  host       = module.rke2_first_server.instances_public_ip[0]
  commands = [
    "timeout=600; while [ ! -f /etc/rancher/rke2/rke2.yaml ]; do sleep 5; done",
    "sudo cat /etc/rancher/rke2/rke2.yaml | sed 's/127.0.0.1/${module.rke2_first_server.instances_public_ip[0]}/g'"
  ]
  user        = local.ssh_username
  private_key = data.local_file.ssh_private_key.content
}

resource "local_file" "kubeconfig_yaml" {
  filename        = local.kubeconfig_file
  content         = ssh_resource.retrieve_kubeconfig.result
  file_permission = "0600"
}

resource "ssh_resource" "verify_cluster" {
  depends_on = [
    local_file.kubeconfig_yaml,
    module.rke2_first_server
  ]
  host        = module.rke2_first_server.instances_public_ip[0]
  user        = local.ssh_username
  private_key = data.local_file.ssh_private_key.content
  commands = [
    "echo 'Waiting for RKE2 node to reach Ready state...'",
    "timeout 300 bash -c 'until sudo /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get nodes | grep -w Ready; do sleep 5; done'",
    "echo 'RKE2 cluster is operational! Node details:'",
    "sudo /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get nodes -o wide"
  ]
}
