locals {
  longhorn_host                     = "longhorn.${var.ingress_ip}.sslip.io"
  rancher_host                      = "rancher.${var.ingress_ip}.sslip.io"
  suse_observability_host           = "observability.${var.ingress_ip}.sslip.io"
  suse_observability_otlp_host      = "otlp-${local.suse_observability_host}"
  suse_observability_otlp_http_host = "otlp-http-${local.suse_observability_host}"
  neuvector_host                    = "neuvector.${var.ingress_ip}.sslip.io"
  openwebui_host                    = "openwebui.${var.ingress_ip}.sslip.io"
  suse_ai_gpu                       = var.suse_ai_enabled && var.is_gpu_instance
  target_node_ips                   = var.node_ips != null ? var.node_ips : []
}

data "local_file" "ssh_private_key" {
  count    = var.ssh_private_key_path != null ? 1 : 0
  filename = var.ssh_private_key_path
}

provider "kubernetes" {
  config_path = var.kubeconfig_file_path
}

provider "helm" {
  kubernetes = {
    config_path = var.kubeconfig_file_path
  }
}

module "longhorn" {
  source                  = "../../modules/distribution/longhorn"
  longhorn_enabled        = var.longhorn_enabled
  longhorn_admin_password = var.longhorn_admin_password
  longhorn_hc_version     = var.longhorn_hc_version
  longhorn_host           = local.longhorn_host
  ssh_private_key         = var.ssh_private_key_path != null ? data.local_file.ssh_private_key[0].content : 0
  ssh_username            = var.ssh_username
  node_ips                = local.target_node_ips
  kubeconfig_path         = var.kubeconfig_file_path
}

module "rancher" {
  source                     = "../../modules/distribution/rancher"
  depends_on                 = [module.longhorn]
  rancher_enabled            = var.rancher_enabled
  rancher_hc_version         = var.rancher_hc_version
  rancher_host               = local.rancher_host
  rancher_bootstrap_password = var.rancher_bootstrap_password
  kubeconfig_path            = var.kubeconfig_file_path
}

module "suse_observability" {
  source                            = "../../modules/distribution/suse-observability"
  depends_on                        = [module.longhorn, module.rancher]
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
  kubeconfig_path                   = var.kubeconfig_file_path
}

module "neuvector" {
  source                     = "../../modules/distribution/neuvector"
  depends_on                 = [module.longhorn, module.rancher]
  neuvector_enabled          = var.neuvector_enabled
  neuvector_hc_version       = var.neuvector_hc_version
  neuvector_version          = var.neuvector_version
  neuvector_host             = local.neuvector_host
  neuvector_admin_password   = var.neuvector_admin_password
  neuvector_controller_count = 3
  neuvector_scanner_count    = 3
  rancher_enabled            = var.rancher_enabled
  rancher_host               = (var.rancher_enabled ? local.rancher_host : null)
  longhorn_enabled           = var.longhorn_enabled
  kubeconfig_path            = var.kubeconfig_file_path
}

module "ai_factory" {
  source                  = "../../modules/distribution/ai-factory"
  depends_on              = [module.rancher]
  ai_factory_enabled      = var.ai_factory_enabled
  ai_factory_hc_version   = var.ai_factory_hc_version
  app_collection_username = var.app_collection_username
  app_collection_password = var.app_collection_password
  nvidia_password         = var.nvidia_password
  suse_registry_password  = var.suse_registry_password
}

module "suse_ai" {
  source                  = "../../modules/distribution/suse-ai"
  depends_on              = [module.rancher]
  suse_ai_enabled         = var.suse_ai_enabled
  suse_ai_gpu             = local.suse_ai_gpu
  milvus_hc_version       = var.milvus_hc_version
  ollama_hc_version       = var.ollama_hc_version
  openwebui_hc_version    = var.openwebui_hc_version
  app_collection_username = var.app_collection_username
  app_collection_password = var.app_collection_password
  openwebui_host          = local.openwebui_host
  kubeconfig_path         = var.kubeconfig_file_path
}
