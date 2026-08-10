resource "random_string" "rke2_token" {
  length  = 32
  special = false
}

locals {
  ssh_private_key_path              = "${path.cwd}/${var.prefix}-ssh_private_key.pem"
  ssh_public_key_path               = "${path.cwd}/${var.prefix}-ssh_public_key.pem"
  ssh_username                      = "opensuse"
  kubeconfig_file                   = "${path.cwd}/${var.prefix}_kubeconfig.yml"
  volume_device                     = "/dev/sdb"
  instance_type                     = var.instance_type
  rke2_token                        = random_string.rke2_token.result
  first_server_url                  = "https://${module.rke2_first_server.instances_public_ip[0]}:9345"
  server_count                      = var.instance_count < 3 ? var.instance_count : 3
  server_nodes                      = var.instance_count == 1 ? [] : [for i in range(2, local.server_count + 1) : tostring(i)]
  worker_count                      = var.instance_count > 3 ? var.instance_count - 3 : 0
  worker_nodes                      = [for i in range(1, local.worker_count + 1) : tostring(i)]
  longhorn_host                     = "longhorn.${module.rke2_first_server.instances_public_ip[0]}.sslip.io"
  rancher_host                      = "rancher.${module.rke2_first_server.instances_public_ip[0]}.sslip.io"
  suse_observability_host           = "observability.${module.rke2_first_server.instances_public_ip[0]}.sslip.io"
  suse_observability_otlp_host      = "otlp-${local.suse_observability_host}"
  suse_observability_otlp_http_host = "otlp-http-${local.suse_observability_host}"
  neuvector_host                    = "neuvector.${module.rke2_first_server.instances_public_ip[0]}.sslip.io"
}

module "identity" {
  source = "../../../modules/identity/ssh/google-cloud"
  prefix = var.prefix
}

module "os_image" {
  source     = "../../../modules/custom-os-image/google-cloud"
  prefix     = var.prefix
  region     = var.region
  project_id = var.project_id
}

module "rke2_first" {
  source        = "../../../modules/distribution/rke2"
  node_role     = "server"
  rke2_token    = local.rke2_token
  rke2_version  = var.rke2_version
  rke2_ingress  = var.rke2_ingress
  volume_device = local.volume_device
}

module "rke2_first_server" {
  source                   = "../../../modules/infrastructure/google-cloud/compute-engine"
  prefix                   = "${var.prefix}-server-1"
  region                   = var.region
  ssh_public_key_content   = module.identity.ssh_public_key
  instance_type            = local.instance_type
  data_disk_size           = var.data_disk_size
  ami_id                   = module.os_image.image_id
  instance_count           = 1
  spot_instance            = var.spot_instance
  create_network_resources = true
  user_data                = module.rke2_first.user_data
}

module "rke2_additional_servers" {
  source        = "../../../modules/distribution/rke2"
  node_role     = "server"
  rke2_token    = local.rke2_token
  rke2_version  = var.rke2_version
  rke2_ingress  = var.rke2_ingress
  volume_device = local.volume_device
  server_url    = local.first_server_url
}

module "rke2_servers" {
  for_each                 = toset(local.server_nodes)
  source                   = "../../../modules/infrastructure/google-cloud/compute-engine"
  prefix                   = "${var.prefix}-server-${each.value}"
  region                   = var.region
  ssh_public_key_content   = module.identity.ssh_public_key
  instance_type            = local.instance_type
  data_disk_size           = var.data_disk_size
  ami_id                   = module.os_image.image_id
  instance_count           = 1
  spot_instance            = var.spot_instance
  create_network_resources = false
  vpc_id                   = module.rke2_first_server.gcp_vpc
  subnet_id                = module.rke2_first_server.gcp_subnet
  user_data                = module.rke2_additional_servers.user_data
}

module "rke2_additional_workers" {
  source        = "../../../modules/distribution/rke2"
  node_role     = "agent"
  rke2_token    = local.rke2_token
  rke2_version  = var.rke2_version
  rke2_ingress  = var.rke2_ingress
  volume_device = local.volume_device
  server_url    = local.first_server_url
}

module "rke2_workers" {
  for_each                 = toset(local.worker_nodes)
  source                   = "../../../modules/infrastructure/google-cloud/compute-engine"
  prefix                   = "${var.prefix}-worker-${each.value}"
  region                   = var.region
  ssh_public_key_content   = module.identity.ssh_public_key
  instance_type            = local.instance_type
  data_disk_size           = var.data_disk_size
  ami_id                   = module.os_image.image_id
  instance_count           = 1
  spot_instance            = var.spot_instance
  create_network_resources = false
  vpc_id                   = module.rke2_first_server.gcp_vpc
  subnet_id                = module.rke2_first_server.gcp_subnet
  user_data                = module.rke2_additional_workers.user_data
}

data "local_file" "ssh_private_key" {
  depends_on = [module.identity]
  filename   = local.ssh_private_key_path
}

resource "ssh_resource" "retrieve_kubeconfig" {
  depends_on = [
    module.rke2_servers,
    module.rke2_workers
  ]
  host = module.rke2_first_server.instances_public_ip[0]
  commands = [
    "timeout=600; while [ ! -f /etc/rancher/rke2/rke2.yaml ]; do sleep 5; done",
    "sudo cat /etc/rancher/rke2/rke2.yaml | sed -e 's/127.0.0.1/${module.rke2_first_server.instances_public_ip[0]}/g' -e '/certificate-authority-data:/c\\    insecure-skip-tls-verify: true'"
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

module "longhorn" {
  source                  = "../../../modules/distribution/longhorn"
  depends_on              = [module.rke2_first_server, module.rke2_servers, module.rke2_workers]
  longhorn_enabled        = var.longhorn_enabled
  longhorn_admin_password = var.longhorn_admin_password
  longhorn_hc_version     = var.longhorn_hc_version
  longhorn_host           = local.longhorn_host
  ssh_private_key         = data.local_file.ssh_private_key.content
  node_ips = concat(
    module.rke2_first_server.instances_public_ip,
    flatten([for m in module.rke2_servers : m.instances_public_ip]),
    flatten([for m in module.rke2_workers : m.instances_public_ip])
  )
  kubeconfig_path = local_file.kubeconfig_yaml.filename
}

module "rancher" {
  source                     = "../../../modules/distribution/rancher"
  depends_on                 = [module.rke2_first_server, module.longhorn]
  rancher_enabled            = var.rancher_enabled
  rancher_hc_version         = var.rancher_hc_version
  rancher_host               = local.rancher_host
  rancher_bootstrap_password = var.rancher_bootstrap_password
  kubeconfig_path            = local_file.kubeconfig_yaml.filename
}

module "suse_observability" {
  source                            = "../../../modules/distribution/suse-observability"
  depends_on                        = [module.rke2_first_server, module.longhorn, module.rancher]
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
  depends_on                 = [module.rke2_first_server, module.longhorn, module.rancher]
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
