resource "random_string" "k3s_token" {
  length  = 32
  special = false
}

data "http" "my_public_ip_address" {
  url = "https://ipv4.icanhazip.com/"
}

locals {
  ssh_private_key_path              = "${path.cwd}/${var.prefix}-ssh_private_key.pem"
  ssh_public_key_path               = "${path.cwd}/${var.prefix}-ssh_public_key.pem"
  ssh_username                      = "opensuse"
  kubeconfig_file                   = "${path.cwd}/${var.prefix}_kubeconfig.yml"
  volume_device                     = "/dev/sdb"
  instance_type                     = var.instance_type
  use_marketplace_image             = var.image_publisher != null && var.image_offer != null && var.image_sku != null && var.image_version != null
  ami_id                            = local.use_marketplace_image ? null : module.os_image[0].image_id
  resource_group                    = local.use_marketplace_image ? azurerm_resource_group.rg[0] : module.os_image[0].resource_group
  first_server_user_data            = module.k3s_first.user_data
  server_user_data                  = module.k3s_additional_servers.user_data
  worker_user_data                  = module.k3s_additional_workers.user_data
  k3s_token                         = random_string.k3s_token.result
  first_server_url                  = "https://${module.k3s_first_server.instances_public_ip}:6443"
  server_count                      = var.instance_count < 3 ? var.instance_count : 3
  server_nodes                      = var.instance_count == 1 ? [] : [for i in range(2, local.server_count + 1) : tostring(i)]
  worker_count                      = var.instance_count > 3 ? var.instance_count - 3 : 0
  worker_nodes                      = [for i in range(1, local.worker_count + 1) : tostring(i)]
  current_public_ip_cidr            = "${chomp(data.http.my_public_ip_address.response_body)}/32"
  public_ip_source_addresses        = length(var.public_ip_source_addresses) > 0 ? var.public_ip_source_addresses : [local.current_public_ip_cidr]
  longhorn_host                     = "longhorn.${module.k3s_first_server.instances_public_ip}.sslip.io"
  rancher_host                      = "rancher.${module.k3s_first_server.instances_public_ip}.sslip.io"
  suse_observability_host           = "observability.${module.k3s_first_server.instances_public_ip}.sslip.io"
  suse_observability_otlp_host      = "otlp-${local.suse_observability_host}"
  suse_observability_otlp_http_host = "otlp-http-${local.suse_observability_host}"
  neuvector_host                    = "neuvector.${module.k3s_first_server.instances_public_ip}.sslip.io"
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

module "os_image" {
  count  = local.use_marketplace_image ? 0 : 1
  source = "../../../modules/custom-os-image/azure"
  prefix = var.prefix
}

resource "azurerm_resource_group" "rg" {
  count    = local.use_marketplace_image ? 1 : 0
  name     = "${var.prefix}-rg"
  location = var.region
}

module "k3s_first" {
  source        = "../../../modules/distribution/k3s"
  node_role     = "server"
  k3s_token     = local.k3s_token
  k3s_version   = var.k3s_version
  volume_device = local.volume_device
}

module "k3s_first_server" {
  source                   = "../../../modules/infrastructure/azure/virtual-machine"
  prefix                   = "${var.prefix}-server-1"
  region                   = var.region
  ssh_public_key_content   = module.identity.ssh_public_key
  instance_type            = local.instance_type
  data_disk_size           = var.data_disk_size
  public_ip_source_addresses = local.public_ip_source_addresses
  ami_id                   = local.ami_id
  image_publisher          = var.image_publisher
  image_offer              = var.image_offer
  image_sku                = var.image_sku
  image_version            = var.image_version
  resource_group           = local.resource_group
  instance_count           = 1
  spot_instance            = var.spot_instance
  create_network_resources = true
  user_data                = local.first_server_user_data
}

module "k3s_additional_servers" {
  source        = "../../../modules/distribution/k3s"
  node_role     = "server"
  k3s_token     = local.k3s_token
  k3s_version   = var.k3s_version
  volume_device = local.volume_device
  server_url    = local.first_server_url
}

module "k3s_servers" {
  for_each                 = toset(local.server_nodes)
  source                   = "../../../modules/infrastructure/azure/virtual-machine"
  prefix                   = "${var.prefix}-server-${each.value}"
  region                   = var.region
  ssh_public_key_content   = module.identity.ssh_public_key
  instance_type            = local.instance_type
  data_disk_size           = var.data_disk_size
  public_ip_source_addresses = local.public_ip_source_addresses
  ami_id                   = local.ami_id
  image_publisher          = var.image_publisher
  image_offer              = var.image_offer
  image_sku                = var.image_sku
  image_version            = var.image_version
  resource_group           = local.resource_group
  instance_count           = 1
  spot_instance            = var.spot_instance
  create_network_resources = false
  subnet_id                = module.k3s_first_server.azure_subnet
  nsg_id                   = module.k3s_first_server.azure_nsg
  user_data                = local.server_user_data
}

module "k3s_additional_workers" {
  source        = "../../../modules/distribution/k3s"
  node_role     = "agent"
  k3s_token     = local.k3s_token
  k3s_version   = var.k3s_version
  volume_device = local.volume_device
  server_url    = local.first_server_url
}

module "k3s_workers" {
  for_each                 = toset(local.worker_nodes)
  source                   = "../../../modules/infrastructure/azure/virtual-machine"
  prefix                   = "${var.prefix}-worker-${each.value}"
  region                   = var.region
  ssh_public_key_content   = module.identity.ssh_public_key
  instance_type            = local.instance_type
  data_disk_size           = var.data_disk_size
  public_ip_source_addresses = local.public_ip_source_addresses
  ami_id                   = local.ami_id
  image_publisher          = var.image_publisher
  image_offer              = var.image_offer
  image_sku                = var.image_sku
  image_version            = var.image_version
  resource_group           = local.resource_group
  instance_count           = 1
  spot_instance            = var.spot_instance
  create_network_resources = false
  subnet_id                = module.k3s_first_server.azure_subnet
  nsg_id                   = module.k3s_first_server.azure_nsg
  user_data                = local.worker_user_data}

data "local_file" "ssh_private_key" {
  depends_on = [module.identity]
  filename   = local.ssh_private_key_path
}

resource "ssh_resource" "retrieve_kubeconfig" {
  depends_on = [
    module.k3s_servers,
    module.k3s_workers
  ]
  host = module.k3s_first_server.instances_public_ip
  commands = [
    "timeout=600; while [ ! -f /etc/rancher/k3s/k3s.yaml ]; do sleep 5; done",
    "sudo cat /etc/rancher/k3s/k3s.yaml | sed -e 's/127.0.0.1/${module.k3s_first_server.instances_public_ip}/g' -e '/certificate-authority-data:/c\\    insecure-skip-tls-verify: true'"
  ]
  user        = local.ssh_username
  private_key = data.local_file.ssh_private_key.content
}

resource "local_file" "kubeconfig_yaml" {
  filename        = local.kubeconfig_file
  content         = ssh_resource.retrieve_kubeconfig.result
  file_permission = "0600"
}

provider "kubernetes" {
  config_path = local_file.kubeconfig_yaml.filename
}

provider "helm" {
  kubernetes = {
    config_path = local_file.kubeconfig_yaml.filename
  }
}

resource "null_resource" "install_prerequisites" {
  count      = local.use_marketplace_image ? var.instance_count : 0
  depends_on = [module.k3s_first_server, module.k3s_additional_servers, module.k3s_servers, module.k3s_workers]
  connection {
    type        = "ssh"
    user        = local.ssh_username
    private_key = data.local_file.ssh_private_key.content
    host = element(
      concat(
        [module.k3s_first_server.instances_public_ip],
        flatten([for m in module.k3s_servers : m.instances_public_ip]),
        flatten([for m in module.k3s_workers : m.instances_public_ip])
      ),
      count.index
    )
  }
  provisioner "remote-exec" {
    inline = [
      "sleep 15",
      "while sudo fuser /var/run/zypp.pid >/dev/null 2>&1; do echo 'Waiting for initial zypper lock...'; sleep 3; done",
      "sudo rm -f /var/run/zypp.pid /var/lib/Zypper/lock",
      "sudo zypper --non-interactive install -y curl tar which python3 open-iscsi nfs-client cryptsetup device-mapper util-linux || true",
      "sudo systemctl enable --now iscsid || true"
    ]
  }
}

module "longhorn" {
  source                  = "../../../modules/distribution/longhorn"
  depends_on              = [module.k3s_first_server, null_resource.install_prerequisites]
  longhorn_enabled        = var.longhorn_enabled
  longhorn_admin_password = var.longhorn_admin_password
  longhorn_hc_version     = var.longhorn_hc_version
  longhorn_host           = local.longhorn_host
  ssh_private_key         = data.local_file.ssh_private_key.content
  node_ips = concat(
    [module.k3s_first_server.instances_public_ip],
    flatten([for m in module.k3s_servers : m.instances_public_ip]),
    flatten([for m in module.k3s_workers : m.instances_public_ip])
  )
  kubeconfig_path = local_file.kubeconfig_yaml.filename
}

module "rancher" {
  source                     = "../../../modules/distribution/rancher"
  depends_on                 = [module.k3s_first_server, module.longhorn]
  rancher_enabled            = var.rancher_enabled
  rancher_hc_version         = var.rancher_hc_version
  rancher_host               = local.rancher_host
  rancher_bootstrap_password = var.rancher_bootstrap_password
  kubeconfig_path            = local_file.kubeconfig_yaml.filename
}

module "suse_observability" {
  source                            = "../../../modules/distribution/suse-observability"
  depends_on                        = [module.k3s_first_server, module.longhorn, module.rancher]
  suse_observability_enabled        = var.suse_observability_enabled
  suse_observability_hc_version     = var.suse_observability_hc_version
  suse_observability_profile        = var.suse_observability_profile
  suse_observability_license        = var.suse_observability_license
  suse_observability_admin_password = var.suse_observability_admin_password
  suse_observability_host           = local.suse_observability_host
  suse_observability_otlp_host      = local.suse_observability_otlp_host
  suse_observability_otlp_http_host = local.suse_observability_otlp_http_host
  suse_observability_rancher_auth   = var.suse_observability_rancher_auth
  rancher_enabled                   = var.rancher_enabled
  rancher_host                      = local.rancher_host
  kubeconfig_path                   = local_file.kubeconfig_yaml.filename
}

module "neuvector" {
  source                     = "../../../modules/distribution/neuvector"
  depends_on                 = [module.k3s_first_server, module.longhorn, module.rancher]
  neuvector_enabled          = var.neuvector_enabled
  neuvector_hc_version       = var.neuvector_hc_version
  neuvector_version          = var.neuvector_version
  neuvector_host             = local.neuvector_host
  neuvector_admin_password   = var.neuvector_admin_password
  neuvector_controller_count = var.instance_count
  neuvector_scanner_count    = (var.instance_count == 1 ? 1 : min(var.instance_count - 1, 3))
  rancher_enabled            = var.rancher_enabled
  rancher_host               = (var.rancher_enabled ? local.rancher_host : null)
  longhorn_enabled           = var.longhorn_enabled
  kubeconfig_path            = local_file.kubeconfig_yaml.filename
}
