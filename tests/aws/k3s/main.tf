resource "random_string" "k3s_token" {
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
  region                            = "us-east-1"
  ssh_private_key_path              = "${path.cwd}/${var.prefix}-ssh_private_key.pem"
  ssh_public_key_path               = "${path.cwd}/${var.prefix}-ssh_public_key.pem"
  ssh_username                      = var.ami_id != "" ? "ec2-user" : "opensuse"
  kubeconfig_file                   = "${path.cwd}/${var.prefix}_kubeconfig.yml"
  volume_device                     = "/dev/nvme1n1"
  ami_id                            = var.ami_id != "" ? var.ami_id : module.os_image[0].image_id
  install_prerequisites             = var.ami_id != "" ? true : false
  k3s_token                         = random_string.k3s_token.result
  current_public_ip_cidr            = "${chomp(data.http.my_public_ip_address.response_body)}/32"
  public_ip_source_addresses        = length(var.public_ip_source_addresses) > 0 ? var.public_ip_source_addresses : [local.current_public_ip_cidr]
  longhorn_host                     = "longhorn.${module.eptoolkit_node.instances_public_ip}.sslip.io"
  rancher_host                      = "rancher.${module.eptoolkit_node.instances_public_ip}.sslip.io"
  suse_observability_host           = "observability.${module.eptoolkit_node.instances_public_ip}.sslip.io"
  suse_observability_otlp_host      = "otlp-${local.suse_observability_host}"
  suse_observability_otlp_http_host = "otlp-http-${local.suse_observability_host}"
}

module "identity" {
  source = "../../../modules/identity/ssh/aws"
  prefix = var.prefix
}

data "local_file" "ssh_private_key" {
  depends_on = [module.identity]
  filename   = local.ssh_private_key_path
}

module "os_image" {
  count  = var.ami_id == "" ? 1 : 0
  source = "../../../modules/custom-os-image/aws"
  prefix = var.prefix
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
  source                     = "../../../modules/infrastructure/aws/ec2"
  prefix                     = "${var.prefix}-server-1"
  region                     = local.region
  ssh_key_name               = module.identity.ssh_key_name
  ssh_key_content            = data.local_file.ssh_private_key.content
  instance_type              = var.instance_type
  data_disk_size             = var.data_disk_size
  public_ip_source_addresses = local.public_ip_source_addresses
  ami_id                     = local.ami_id
  ssh_username               = local.ssh_username
  instance_count             = 1
  spot_instance              = false
  create_network_resources   = true
  user_data                  = module.k3s_first.user_data
}

resource "ssh_resource" "retrieve_kubeconfig" {
  depends_on = [module.eptoolkit_node]
  host       = module.eptoolkit_node.instances_public_ip
  commands = [
    "timeout 600; while [ ! -f /etc/rancher/k3s/k3s.yaml ]; do sleep 5; done",
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
  depends_on  = [local_file.kubeconfig_yaml, module.eptoolkit_node]
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
  depends_on              = [module.eptoolkit_node, local_file.kubeconfig_yaml]
  longhorn_enabled        = var.longhorn_enabled
  longhorn_admin_password = var.longhorn_admin_password
  longhorn_hc_version     = var.longhorn_hc_version
  longhorn_host           = local.longhorn_host
  ssh_private_key         = data.local_file.ssh_private_key.content
  node_ips                = [module.eptoolkit_node.instances_public_ip]
  kubeconfig_path         = local_file.kubeconfig_yaml.filename
}

module "rancher" {
  source                     = "../../../modules/distribution/rancher"
  depends_on                 = [module.eptoolkit_node, local_file.kubeconfig_yaml, module.longhorn]
  rancher_enabled            = var.rancher_enabled
  rancher_hc_version         = var.rancher_hc_version
  rancher_host               = local.rancher_host
  rancher_bootstrap_password = var.rancher_bootstrap_password
  kubeconfig_path            = local_file.kubeconfig_yaml.filename
}

resource "ssh_resource" "single_node_watchdog" {
  count       = var.suse_observability_enabled ? 1 : 0
  depends_on  = [module.eptoolkit_node, local_file.kubeconfig_yaml, module.rancher]
  host        = module.eptoolkit_node.instances_public_ip
  user        = local.ssh_username
  private_key = data.local_file.ssh_private_key.content
  commands = [
    <<-EOF
    nohup bash -c '
      # Apply global Longhorn settings for single-node cluster execution
      sudo /usr/local/bin/k3s kubectl -n longhorn-system patch settings.longhorn.io default-replica-count --type=merge -p "{\"value\":\"1\"}" 2>/dev/null || true
      sudo /usr/local/bin/k3s kubectl -n longhorn-system patch settings.longhorn.io replica-replenishment-wait-interval --type=merge -p "{\"value\":\"0\"}" 2>/dev/null || true
      # Watchdog monitoring loop (~15 minutes: 300 cycles * 3 seconds)
      for i in {1..300}; do
        # Scale down SUSE Observability StatefulSets and Deployments to 1 replica
        sudo /usr/local/bin/k3s kubectl -n suse-observability scale statefulsets --all --replicas=1 2>/dev/null || true
        sudo /usr/local/bin/k3s kubectl -n suse-observability scale deployments --all --replicas=1 2>/dev/null || true
        # Detect and patch any Longhorn volumes requesting more than 1 replica
        for vol in $(sudo /usr/local/bin/k3s kubectl -n longhorn-system get volumes.longhorn.io -o jsonpath="{.items[?(@.spec.numberOfReplicas>1)].metadata.name}" 2>/dev/null); do
          sudo /usr/local/bin/k3s kubectl -n longhorn-system patch volumes.longhorn.io "$vol" --type=merge -p "{\"spec\":{\"numberOfReplicas\":1}}" 2>/dev/null || true
        done
        sleep 3
      done
    ' >/tmp/watchdog.log 2>&1 &
    EOF
  ]
}

module "suse_observability" {
  source                            = "../../../modules/distribution/suse-observability"
  depends_on                        = [module.eptoolkit_node, local_file.kubeconfig_yaml, module.longhorn, module.rancher, ssh_resource.single_node_watchdog]
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

resource "ssh_resource" "verify_pods" {
  depends_on  = [local_file.kubeconfig_yaml, module.eptoolkit_node, module.longhorn, module.rancher, module.suse_observability]
  host        = module.eptoolkit_node.instances_public_ip
  user        = local.ssh_username
  private_key = data.local_file.ssh_private_key.content
  commands = [
    "echo 'Waiting for K3s node to reach Ready state...'",
    "timeout 300 bash -c 'until sudo /usr/local/bin/k3s kubectl --kubeconfig /etc/rancher/k3s/k3s.yaml get nodes | grep -w Ready; do sleep 5; done'",
    "echo 'K3s cluster is operational!'",
    "sudo /usr/local/bin/k3s kubectl --kubeconfig /etc/rancher/k3s/k3s.yaml get nodes -o wide",
    "echo 'Pod status across all namespaces:'",
    "sudo /usr/local/bin/k3s kubectl --kubeconfig /etc/rancher/k3s/k3s.yaml get pods -A"
  ]
}
