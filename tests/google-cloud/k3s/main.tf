resource "random_string" "k3s_token" {
  length  = 32
  special = false
}

data "google_compute_image" "custom_image" {
  count   = var.ami_id != "" ? 1 : 0
  name    = var.ami_id
  project = "opensuse-cloud"
}

data "http" "my_public_ip_address" {
  url = "https://api4.ipify.org"
}

locals {
  region                     = "europe-west8"
  instance_type              = "n2-standard-4"
  ssh_private_key_path       = "${path.cwd}/${var.prefix}-ssh_private_key.pem"
  ssh_public_key_path        = "${path.cwd}/${var.prefix}-ssh_public_key.pem"
  ssh_username               = "opensuse"
  kubeconfig_file            = "${path.cwd}/${var.prefix}_kubeconfig.yml"
  volume_device              = "/dev/sdb"
  ami_id                     = var.ami_id != "" ? data.google_compute_image.custom_image[0].self_link : module.os_image[0].image_id
  install_prerequisites      = var.ami_id != "" ? true : false
  gcp_prep_script            = <<-EOF
    #!/bin/bash
    set -e
    zypper --non-interactive install -y curl tar which python3 cloud-init || true
    systemctl enable --now cloud-init.service || true
    cloud-init init --local || true
    cloud-init init || true
    cloud-init modules --mode config || true
    cloud-init modules --mode final || true
  EOF
  startup_script             = var.ami_id != "" ? local.gcp_prep_script : null
  k3s_token                  = random_string.k3s_token.result
  current_public_ip_cidr     = "${chomp(data.http.my_public_ip_address.response_body)}/32"
  public_ip_source_addresses = length(var.public_ip_source_addresses) > 0 ? var.public_ip_source_addresses : [local.current_public_ip_cidr]
}

module "identity" {
  source = "../../../modules/identity/ssh/google-cloud"
  prefix = var.prefix
}

data "local_file" "ssh_private_key" {
  depends_on = [module.identity]
  filename   = local.ssh_private_key_path
}

module "os_image" {
  count      = var.ami_id == "" ? 1 : 0
  source     = "../../../modules/custom-os-image/google-cloud"
  prefix     = var.prefix
  region     = local.region
  project_id = var.project_id
}

module "k3s_first" {
  source                = "../../../modules/distribution/k3s"
  node_role             = "server"
  k3s_token             = local.k3s_token
  k3s_version           = var.k3s_version
  volume_device         = local.volume_device
  is_gpu_instance       = false
  install_prerequisites = local.install_prerequisites
}

module "eptoolkit_node" {
  source                     = "../../../modules/infrastructure/google-cloud/compute-engine"
  prefix                     = "${var.prefix}-server-1"
  region                     = local.region
  zone                       = var.zone
  ssh_public_key_content     = module.identity.ssh_public_key
  ssh_private_key_content    = module.identity.ssh_private_key
  instance_type              = local.instance_type
  gpu_count                  = 0
  gpu_type                   = null
  data_disk_size             = var.data_disk_size
  public_ip_source_addresses = local.public_ip_source_addresses
  ami_id                     = local.ami_id
  instance_count             = 1
  spot_instance              = false
  create_network_resources   = true
  startup_script             = local.startup_script
  user_data                  = module.k3s_first.user_data
}

resource "ssh_resource" "retrieve_kubeconfig" {
  depends_on = [module.eptoolkit_node]
  host       = module.eptoolkit_node.instances_public_ip[0]
  commands = [
    "timeout=600; while [ ! -f /etc/rancher/k3s/k3s.yaml ]; do sleep 5; done",
    "sudo cat /etc/rancher/k3s/k3s.yaml | sed -e 's/127.0.0.1/${module.eptoolkit_node.instances_public_ip[0]}/g' -e '/certificate-authority-data:/c\\    insecure-skip-tls-verify: true'"
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
    module.eptoolkit_node
  ]
  host        = module.eptoolkit_node.instances_public_ip[0]
  user        = local.ssh_username
  private_key = data.local_file.ssh_private_key.content
  commands = [
    "echo 'Waiting for K3s node to reach Ready state...'",
    "timeout 300 bash -c 'until sudo /usr/local/bin/k3s kubectl --kubeconfig /etc/rancher/k3s/k3s.yaml get nodes | grep -w Ready; do sleep 5; done'",
    "echo 'K3s cluster is operational! Node details:'",
    "sudo /usr/local/bin/k3s kubectl --kubeconfig /etc/rancher/k3s/k3s.yaml get nodes -o wide"
  ]
}
