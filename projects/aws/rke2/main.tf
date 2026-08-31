resource "random_string" "rke2_token" {
  length  = 32
  special = false
}

data "http" "my_public_ip_address" {
  url = "https://ipv4.icanhazip.com/"
}

data "aws_ami" "ami_validation" {
  count  = var.ami_id != "" ? 1 : 0
  owners = ["679593333241", "aws-marketplace", "amazon", "self"]
  filter {
    name   = "image-id"
    values = [var.ami_id]
  }
  filter {
    name   = "name"
    values = ["*openSUSE*15*6*", "*openSUSE*16*0*"]
  }
}

locals {
  ssh_private_key_path              = "${path.cwd}/${var.prefix}-ssh_private_key.pem"
  ssh_public_key_path               = "${path.cwd}/${var.prefix}-ssh_public_key.pem"
  ssh_username                      = var.ami_id != "" ? "ec2-user" : "opensuse"
  kubeconfig_file                   = "${path.cwd}/${var.prefix}_kubeconfig.yml"
  volume_device                     = "/dev/nvme1n1"
  instance_type                     = var.instance_type
  ami_id                            = var.ami_id != "" ? var.ami_id : module.os_image[0].image_id
  first_server_user_data            = module.rke2_first.user_data
  server_user_data                  = module.rke2_additional_servers.user_data
  worker_user_data                  = module.rke2_additional_workers.user_data
  rke2_token                        = random_string.rke2_token.result
  first_server_url                  = "https://${module.rke2_first_server.instances_public_ip}:9345"
  server_count                      = var.instance_count < 3 ? var.instance_count : 3
  server_nodes                      = var.instance_count == 1 ? [] : [for i in range(2, local.server_count + 1) : tostring(i)]
  worker_count                      = var.instance_count > 3 ? var.instance_count - 3 : 0
  worker_nodes                      = [for i in range(1, local.worker_count + 1) : tostring(i)]
  current_public_ip_cidr            = "${chomp(data.http.my_public_ip_address.response_body)}/32"
  public_ip_source_addresses        = length(var.public_ip_source_addresses) > 0 ? var.public_ip_source_addresses : [local.current_public_ip_cidr]
  longhorn_host                     = "longhorn.${module.rke2_first_server.instances_public_ip}.sslip.io"
  rancher_host                      = "rancher.${module.rke2_first_server.instances_public_ip}.sslip.io"
  suse_observability_host           = "observability.${module.rke2_first_server.instances_public_ip}.sslip.io"
  suse_observability_otlp_host      = "otlp-${local.suse_observability_host}"
  suse_observability_otlp_http_host = "otlp-http-${local.suse_observability_host}"
  neuvector_host                    = "neuvector.${module.rke2_first_server.instances_public_ip}.sslip.io"
}

module "identity" {
  source = "../../../modules/identity/ssh/aws"
  prefix = var.prefix
}

module "os_image" {
  count  = var.ami_id == "" ? 1 : 0
  source = "../../../modules/custom-os-image/aws"
  prefix = var.prefix
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
  source                     = "../../../modules/infrastructure/aws/ec2"
  prefix                     = "${var.prefix}-server-1"
  region                     = var.region
  ssh_key_name               = module.identity.ssh_key_name
  ssh_key_content            = data.local_file.ssh_private_key.content
  instance_type              = local.instance_type
  data_disk_size             = var.data_disk_size
  public_ip_source_addresses = local.public_ip_source_addresses
  ami_id                     = local.ami_id
  instance_count             = 1
  spot_instance              = var.spot_instance
  create_network_resources   = true
  user_data                  = local.first_server_user_data
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
  for_each                   = toset(local.server_nodes)
  source                     = "../../../modules/infrastructure/aws/ec2"
  prefix                     = "${var.prefix}-server-${each.value}"
  region                     = var.region
  ssh_key_name               = module.identity.ssh_key_name
  ssh_key_content            = data.local_file.ssh_private_key.content
  instance_type              = local.instance_type
  data_disk_size             = var.data_disk_size
  public_ip_source_addresses = local.public_ip_source_addresses
  ami_id                     = local.ami_id
  instance_count             = 1
  spot_instance              = var.spot_instance
  create_network_resources   = false
  security_group_id          = module.rke2_first_server.aws_security_group
  subnet_id                  = module.rke2_first_server.aws_subnet
  user_data                  = local.server_user_data
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
  for_each                   = toset(local.worker_nodes)
  source                     = "../../../modules/infrastructure/aws/ec2"
  prefix                     = "${var.prefix}-worker-${each.value}"
  region                     = var.region
  ssh_key_name               = module.identity.ssh_key_name
  ssh_key_content            = data.local_file.ssh_private_key.content
  instance_type              = local.instance_type
  data_disk_size             = var.data_disk_size
  public_ip_source_addresses = local.public_ip_source_addresses
  ami_id                     = local.ami_id
  instance_count             = 1
  spot_instance              = var.spot_instance
  create_network_resources   = false
  security_group_id          = module.rke2_first_server.aws_security_group
  subnet_id                  = module.rke2_first_server.aws_subnet
  user_data                  = local.worker_user_data
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
  host = module.rke2_first_server.instances_public_ip
  commands = [
    "timeout=600; while [ ! -f /etc/rancher/rke2/rke2.yaml ]; do sleep 5; done",
    "sudo cat /etc/rancher/rke2/rke2.yaml | sed -e 's/127.0.0.1/${module.rke2_first_server.instances_public_ip}/g' -e '/certificate-authority-data:/c\\    insecure-skip-tls-verify: true'"
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
  count      = var.ami_id != "" ? var.instance_count : 0
  depends_on = [module.rke2_first_server, module.rke2_servers, module.rke2_workers]
  connection {
    type        = "ssh"
    user        = local.ssh_username
    private_key = data.local_file.ssh_private_key.content
    host = element(
      concat(
        [module.rke2_first_server.instances_public_ip],
        flatten([for m in module.rke2_servers : m.instances_public_ip]),
        flatten([for m in module.rke2_workers : m.instances_public_ip])
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
  depends_on              = [module.rke2_first_server, null_resource.install_prerequisites]
  longhorn_enabled        = var.longhorn_enabled
  longhorn_admin_password = var.longhorn_admin_password
  longhorn_hc_version     = var.longhorn_hc_version
  longhorn_host           = local.longhorn_host
  ssh_username            = local.ssh_username
  ssh_private_key         = data.local_file.ssh_private_key.content
  node_ips = concat(
    [module.rke2_first_server.instances_public_ip],
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
