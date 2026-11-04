resource "random_string" "k3s_token" {
  length  = 32
  special = false
}

data "http" "my_public_ip_address" {
  url = "https://ipv4.icanhazip.com/"
}

locals {
  region                     = "italynorth"
  ssh_private_key_path       = "${path.cwd}/${var.prefix}-ssh_private_key.pem"
  ssh_public_key_path        = "${path.cwd}/${var.prefix}-ssh_public_key.pem"
  ssh_username               = "opensuse"
  kubeconfig_file            = "${path.cwd}/${var.prefix}_kubeconfig.yml"
  is_gpu_instance            = can(regex("^Standard_NC", var.instance_type))
  volume_device              = local.is_gpu_instance ? "/dev/sdc" : "/dev/sdb"
  instance_type              = var.instance_type
  use_marketplace_image      = var.image_publisher != null && var.image_offer != null && var.image_sku != null && var.image_version != null
  ami_id                     = local.use_marketplace_image ? null : module.os_image[0].image_id
  resource_group             = local.use_marketplace_image ? azurerm_resource_group.rg[0] : module.os_image[0].resource_group
  k3s_token                  = random_string.k3s_token.result
  current_public_ip_cidr     = "${chomp(data.http.my_public_ip_address.response_body)}/32"
  public_ip_source_addresses = length(var.public_ip_source_addresses) > 0 ? var.public_ip_source_addresses : [local.current_public_ip_cidr]
}

check "marketplace_image_variables" {
  assert {
    condition = (
      (var.image_publisher == null && var.image_offer == null && var.image_sku == null && var.image_version == null) ||
      (var.image_publisher != null && var.image_offer != null && var.image_sku != null && var.image_version != null)
    )
    error_message = "All marketplace image variables (image_publisher, image_offer, image_sku, image_version) must either be all specified or all left as null."
  }
}

module "identity" {
  source = "../../../modules/identity/ssh/azure"
  prefix = var.prefix
}

data "local_file" "ssh_private_key" {
  depends_on = [module.identity]
  filename   = local.ssh_private_key_path
}

module "os_image" {
  count  = local.use_marketplace_image ? 0 : 1
  source = "../../../modules/custom-os-image/azure"
  prefix = var.prefix
}

resource "azurerm_resource_group" "rg" {
  count    = local.use_marketplace_image ? 1 : 0
  name     = "${var.prefix}-rg"
  location = local.region
}

module "k3s_first" {
  source                = "../../../modules/distribution/k3s"
  node_role             = "server"
  k3s_token             = local.k3s_token
  k3s_version           = var.k3s_version
  volume_device         = local.volume_device
  is_gpu_instance       = local.is_gpu_instance
  install_prerequisites = local.use_marketplace_image
}

module "eptoolkit_node" {
  source                          = "../../../modules/infrastructure/azure/virtual-machine"
  prefix                          = "${var.prefix}-server-1"
  region                          = local.region
  zone                            = var.zone
  ssh_public_key_content          = module.identity.ssh_public_key
  ssh_private_key_content         = module.identity.ssh_private_key
  instance_type                   = local.instance_type
  data_disk_size                  = var.data_disk_size
  disk_iops_read_write            = var.disk_iops_read_write
  disk_throughput_mbps_read_write = var.disk_throughput_mbps_read_write
  public_ip_source_addresses      = local.public_ip_source_addresses
  ami_id                          = local.ami_id
  image_publisher                 = var.image_publisher
  image_offer                     = var.image_offer
  image_sku                       = var.image_sku
  image_version                   = var.image_version
  resource_group                  = local.resource_group
  instance_count                  = 1
  spot_instance                   = var.spot_instance
  create_network_resources        = true
  user_data                       = module.k3s_first.user_data
}

resource "ssh_resource" "retrieve_kubeconfig" {
  depends_on = [module.eptoolkit_node]
  host       = module.eptoolkit_node.instances_public_ip
  commands = [
    "timeout=600; while [ ! -f /etc/rancher/k3s/k3s.yaml ]; do sleep 5; done",
    "sudo cat /etc/rancher/k3s/k3s.yaml | sed -e 's/127.0.0.1/${module.eptoolkit_node.instances_public_ip}/g' -e '/certificate-authority-data:/c\\    insecure-skip-tls-verify: true'"
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
  host        = module.eptoolkit_node.instances_public_ip
  user        = local.ssh_username
  private_key = data.local_file.ssh_private_key.content
  commands = [
    "echo 'Waiting for K3s node to reach Ready state...'",
    "timeout 300 bash -c 'until sudo /usr/local/bin/k3s kubectl --kubeconfig /etc/rancher/k3s/k3s.yaml get nodes | grep -w Ready; do sleep 5; done'",
    "echo 'K3s cluster is operational! Node details:'",
    "sudo /usr/local/bin/k3s kubectl --kubeconfig /etc/rancher/k3s/k3s.yaml get nodes -o wide"
  ]
}
