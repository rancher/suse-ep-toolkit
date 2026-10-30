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
  region                     = "us-east-1"
  instance_type              = "m8i.4xlarge"
  ssh_private_key_path       = "${path.cwd}/${var.prefix}-ssh_private_key.pem"
  ssh_public_key_path        = "${path.cwd}/${var.prefix}-ssh_public_key.pem"
  ssh_username               = var.ami_id != "" ? "ec2-user" : "opensuse"
  kubeconfig_file            = "${path.cwd}/${var.prefix}_kubeconfig.yml"
  volume_device              = "/dev/nvme1n1"
  ami_id                     = var.ami_id != "" ? var.ami_id : module.os_image[0].image_id
  install_prerequisites      = var.ami_id != "" ? true : false
  rke2_token                 = random_string.rke2_token.result
  current_public_ip_cidr     = "${chomp(data.http.my_public_ip_address.response_body)}/32"
  public_ip_source_addresses = length(var.public_ip_source_addresses) > 0 ? var.public_ip_source_addresses : [local.current_public_ip_cidr]
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

module "rke2_first" {
  source                = "../../../modules/distribution/rke2"
  node_role             = "server"
  rke2_token            = local.rke2_token
  rke2_version          = var.rke2_version
  rke2_ingress          = var.rke2_ingress
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
  instance_type              = local.instance_type
  data_disk_size             = var.data_disk_size
  public_ip_source_addresses = local.public_ip_source_addresses
  ami_id                     = local.ami_id
  ssh_username               = local.ssh_username
  instance_count             = 1
  spot_instance              = false
  create_network_resources   = true
  user_data                  = module.rke2_first.user_data
}

resource "ssh_resource" "retrieve_kubeconfig" {
  depends_on = [module.eptoolkit_node]
  host       = module.eptoolkit_node.instances_public_ip
  commands = [
    "timeout=600; while [ ! -f /etc/rancher/rke2/rke2.yaml ]; do sleep 5; done",
    "sudo cat /etc/rancher/rke2/rke2.yaml | sed -e 's/127.0.0.1/${module.eptoolkit_node.instances_public_ip}/g' -e '/certificate-authority-data:/c\\    insecure-skip-tls-verify: true'"
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
    "echo 'Waiting for RKE2 node to reach Ready state...'",
    "timeout 300 bash -c 'until sudo /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get nodes | grep -w Ready; do sleep 5; done'",
    "echo 'RKE2 cluster is operational! Node details:'",
    "sudo /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get nodes -o wide"
  ]
}
