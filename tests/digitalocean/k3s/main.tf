resource "random_string" "k3s_token" {
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
  k3s_token                  = random_string.k3s_token.result
  current_public_ip_cidr     = "${chomp(data.http.my_public_ip_address.response_body)}/32"
  public_ip_source_addresses = length(var.public_ip_source_addresses) > 0 ? var.public_ip_source_addresses : [local.current_public_ip_cidr]
}

module "identity" {
  source = "../../../modules/identity/ssh/digitalocean"
  prefix = var.prefix
}

data "local_file" "ssh_private_key" {
  depends_on = [module.k3s_first_server]
  filename   = local.ssh_private_key_path
}

module "os_image" {
  source = "../../../modules/custom-os-image/digitalocean"
  prefix = var.prefix
  region = local.region
}

module "k3s_first" {
  source                = "../../../modules/distribution/k3s"
  node_role             = "server"
  k3s_token             = local.k3s_token
  k3s_version           = var.k3s_version
  volume_device         = local.volume_device
  is_gpu_instance       = false
  install_prerequisites = false
}

module "k3s_first_server" {
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
  user_data                  = module.k3s_first.user_data
}

resource "ssh_resource" "retrieve_kubeconfig" {
  depends_on = [module.k3s_first_server]
  host       = module.k3s_first_server.instances_public_ip[0]
  commands = [
    "timeout=600; while [ ! -f /etc/rancher/k3s/k3s.yaml ]; do sleep 5; done",
    "sudo cat /etc/rancher/k3s/k3s.yaml | sed 's/127.0.0.1/${module.k3s_first_server.instances_public_ip[0]}/g'"
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
    module.k3s_first_server
  ]
  host        = module.k3s_first_server.instances_public_ip[0]
  user        = local.ssh_username
  private_key = data.local_file.ssh_private_key.content
  commands = [
    "echo 'Waiting for K3s node to reach Ready state...'",
    "timeout 300 bash -c 'until sudo /usr/local/bin/k3s kubectl --kubeconfig /etc/rancher/k3s/k3s.yaml get nodes | grep -w Ready; do sleep 5; done'",
    "echo 'K3s cluster is operational! Node details:'",
    "sudo /usr/local/bin/k3s kubectl --kubeconfig /etc/rancher/k3s/k3s.yaml get nodes -o wide"
  ]
}
