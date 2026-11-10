variable "node_ips" {
  description = "Specifies a list of node IP addresses used to install Longhorn dependencies via SSH on SUSE Linux distributions. If empty, prerequisites must be pre-installed on the nodes. Default is '[]'."
  type        = list(string)
  default     = []
}

variable "ingress_ip" {
  description = "Specifies the IP address used to configure ingress resources on the RKE2/K3s cluster. Default is 'null'."
  type        = string
  default     = null
}

variable "ssh_private_key_path" {
  description = "Specifies the file path to the SSH private key used for node authentication. Default is 'null'."
  type        = string
  default     = null
  sensitive   = true
}

variable "ssh_username" {
  description = "Specifies the SSH username used to access the cluster nodes. Default is 'opensuse'."
  type        = string
  default     = "opensuse"
}

variable "kubeconfig_file_path" {
  description = "Specifies the file path to the kubeconfig file used to interact with the Kubernetes cluster. Default is 'null'."
  type        = string
  default     = null
}

variable "is_gpu_instance" {
  description = "Specifies whether the cluster nodes are equipped with GPUs. Default is 'false'."
  type        = bool
  default     = false
}

variable "longhorn_enabled" {
  description = "Specifies whether Longhorn should be installed on the Kubernetes cluster. Default is 'false'."
  type        = bool
  default     = false
}

variable "longhorn_admin_password" {
  description = "Specifies the Longhorn administrator password used for securing the Longhorn UI via basic authentication. Must be at least 12 characters and include at least 1 uppercase letter, 1 number, and 1 special character. Default is 'null'."
  type        = string
  default     = null
  sensitive   = true
  validation {
    condition = (
      var.longhorn_enabled == false ||
      (
        var.longhorn_admin_password != null &&
        length(var.longhorn_admin_password) >= 12 &&
        can(regex("[A-Z]", var.longhorn_admin_password)) &&
        can(regex("[0-9]", var.longhorn_admin_password)) &&
        can(regex("[^A-Za-z0-9]", var.longhorn_admin_password))
      )
    )
    error_message = "When longhorn_enabled is true, longhorn_admin_password must be at least 12 characters long and include at least 1 uppercase letter, 1 number, and 1 special character."
  }
}

variable "longhorn_hc_version" {
  description = "Specifies the Longhorn Helm chart version to install. Default is 'null' (latest version)."
  type        = string
  default     = null
}

variable "rancher_enabled" {
  description = "Specifies whether Rancher should be installed on the Kubernetes cluster. Default is 'false'."
  type        = bool
  default     = false
  validation {
    condition = (
      var.rancher_enabled == false ||
      var.longhorn_enabled == true
    )
    error_message = "When rancher_enabled is true, longhorn_enabled must also be true."
  }
}

variable "rancher_hc_version" {
  description = "Specifies the Rancher Helm chart version to install. Default is 'null' (latest version)."
  type        = string
  default     = null
}

variable "rancher_bootstrap_password" {
  description = "Specifies the bootstrap administrator password used during Rancher installation. Must be at least 12 characters and include at least 1 uppercase letter, 1 number, and 1 special character when Rancher is enabled. Default is empty."
  type        = string
  default     = ""
  sensitive   = true
  validation {
    condition = (
      var.rancher_enabled == false ||
      (
        var.rancher_bootstrap_password != null &&
        length(var.rancher_bootstrap_password) >= 12 &&
        can(regex("[A-Z]", var.rancher_bootstrap_password)) &&
        can(regex("[0-9]", var.rancher_bootstrap_password)) &&
        can(regex("[^A-Za-z0-9]", var.rancher_bootstrap_password))
      )
    )
    error_message = "When rancher_enabled is true, rancher_bootstrap_password must be at least 12 characters long and include at least 1 uppercase letter, 1 number, and 1 special character."
  }
}

variable "suse_observability_enabled" {
  description = "Specifies whether SUSE Observability should be installed on the Kubernetes cluster. Default is 'false'."
  type        = bool
  default     = false
  validation {
    condition = (
      var.suse_observability_enabled == false ||
      var.longhorn_enabled == true
    )
    error_message = "When suse_observability_enabled is true, longhorn_enabled must also be true."
  }
}

variable "suse_observability_hc_version" {
  description = "Specifies the SUSE Observability Helm chart version to install. Default is null (latest version). Default is 'null'."
  type        = string
  default     = null
}

variable "suse_observability_profile" {
  description = "Specifies the SUSE Observability deployment sizing profile. Supported values depend on the Helm chart configuration. Default is 'trial'."
  type        = string
  default     = "trial"
}

variable "suse_observability_license" {
  description = "Specifies the SUSE Observability license key required for installation. Default is 'null'."
  type        = string
  default     = ""
  sensitive   = true
  validation {
    condition = (
      var.suse_observability_enabled == false ||
      (
        var.suse_observability_license != null &&
        length(var.suse_observability_license) > 0
      )
    )
    error_message = "When suse_observability_enabled is true, suse_observability_license must be specified."
  }
}

variable "suse_observability_admin_password" {
  description = "Specifies the SUSE Observability administrator password used during installation. Must be at least 12 characters and include at least 1 uppercase letter, 1 number, and 1 special character. Default is empty."
  type        = string
  default     = ""
  sensitive   = true
  validation {
    condition = (
      var.suse_observability_enabled == false ||
      (
        var.suse_observability_admin_password != null &&
        length(var.suse_observability_admin_password) >= 12 &&
        can(regex("[A-Z]", var.suse_observability_admin_password)) &&
        can(regex("[0-9]", var.suse_observability_admin_password)) &&
        can(regex("[^A-Za-z0-9]", var.suse_observability_admin_password))
      )
    )
    error_message = "When suse_observability_enabled is true, suse_observability_admin_password must be at least 12 characters long and include at least 1 uppercase letter, 1 number, and 1 special character."
  }
}

variable "suse_observability_rancher_auth" {
  description = "Specifies whether Rancher should be used as the OIDC provider for SUSE Observability. Default is 'false'."
  type        = bool
  default     = false
  validation {
    condition     = var.suse_observability_rancher_auth == false || var.rancher_enabled
    error_message = "When suse_observability_rancher_auth is true, Rancher must be enabled."
  }
}

variable "neuvector_enabled" {
  description = "Specifies whether NeuVector should be installed on the Kubernetes cluster. Default is 'false'."
  type        = bool
  default     = false
}

variable "neuvector_hc_version" {
  description = "Specifies the NeuVector Helm chart version to install. Default is 'null' (latest version)."
  type        = string
  default     = null
}

variable "neuvector_version" {
  description = "Specifies the NeuVector application version deployed by the Helm chart. Default is empty (chart default version)."
  type        = string
  default     = ""
  validation {
    condition = (
      var.neuvector_version == "" ||
      can(regex("^\\d+\\.\\d+\\.\\d+$", var.neuvector_version))
    )
    error_message = "neuvector_version must use semantic version format 'x.y.z' (e.g. 5.5.1 or 5.0.1)."
  }
}

variable "neuvector_admin_password" {
  description = "Specifies the NeuVector administrator password. Must be at least 12 characters and include at least 1 uppercase letter, 1 number, and 1 special character. Default is empty."
  type        = string
  default     = ""
  sensitive   = true
  validation {
    condition = (
      var.neuvector_enabled == false ||
      (
        var.neuvector_admin_password != null &&
        length(var.neuvector_admin_password) >= 12 &&
        can(regex("[A-Z]", var.neuvector_admin_password)) &&
        can(regex("[0-9]", var.neuvector_admin_password)) &&
        can(regex("[^A-Za-z0-9]", var.neuvector_admin_password))
      )
    )
    error_message = "Password must be ≥12 chars, include at least 1 uppercase letter, 1 number, and 1 special character."
  }
}

variable "neuvector_controller_count" {
  description = "Specifies the number of NeuVector controller replicas to deploy. Default is 'null'."
  type        = number
  default     = null
}

variable "neuvector_scanner_count" {
  description = "Specifies the number of NeuVector scanner replicas to deploy. Default is 'null'."
  type        = number
  default     = null
}

variable "ai_factory_enabled" {
  description = "Specifies whether SUSE AI Factory should be installed on the Kubernetes cluster. Default is 'false'."
  type        = bool
  default     = false
  validation {
    condition = (
      var.ai_factory_enabled == false ||
      var.rancher_enabled == true
    )
    error_message = "When ai_factory_enabled is true, rancher_enabled must also be set to true."
  }
}

variable "ai_factory_hc_version" {
  description = "Specifies the SUSE AI Factory Helm chart version to install. Default is 'null' (latest version)."
  type        = string
  default     = null
}

variable "suse_ai_enabled" {
  description = "Specifies whether SUSE AI stack with GPU should be installed on the Kubernetes cluster. Default is 'false'."
  type        = bool
  default     = false
  validation {
    condition = (
      var.suse_ai_enabled == false ||
      var.rancher_enabled == true &&
      var.longhorn_enabled == true
    )
    error_message = "When suse_ai_enabled is true, longhorn_enabled and rancher_enabled must also be set to true."
  }
}

variable "suse_ai_gpu" {
  description = "Enable GPU support for SUSE AI. If true, requires a GPU-capable instance_type. Default is 'false'."
  type        = bool
  default     = false
}

variable "milvus_hc_version" {
  description = "Specifies the Milvus Helm chart version to install. Default is '4.2.2'."
  type        = string
  default     = "4.2.2"
}

variable "ollama_hc_version" {
  description = "Specifies the Ollama Helm chart version to install. Default is null (latest version)."
  type        = string
  default     = null
}

variable "openwebui_hc_version" {
  description = "Specifies the Open WebUI Helm chart version to install. Default is null (latest version)."
  type        = string
  default     = null
}

variable "app_collection_username" {
  description = "Specifies the SUSE AppCo username. Default is 'null'."
  type        = string
  default     = null

  validation {
    condition = (
      (var.suse_ai_enabled || var.ai_factory_enabled) ?
      (var.app_collection_username != null && length(trimspace(var.app_collection_username)) > 0) :
      true
    )
    error_message = "When suse_ai_enabled or ai_factory_enabled is true, app_collection_username must be provided to pull the images from SUSE Registry."
  }
}

variable "app_collection_password" {
  description = "Specifies the SUSE AppCo password. Default is 'null'."
  type        = string
  default     = null
  validation {
    condition = (
      (var.suse_ai_enabled || var.ai_factory_enabled) ?
      (var.app_collection_password != null && length(trimspace(var.app_collection_password)) > 0) :
      true
    )
    error_message = "When suse_ai_enabled or ai_factory_enabled is true, app_collection_password must be provided to pull the images from SUSE Registry."
  }
}

variable "nvidia_password" {
  description = "Specifies the NVIDIA password. Default is 'null'."
  type        = string
  default     = null
}

variable "suse_registry_password" {
  description = "Specifies the SUSE registry password. Default is 'null'."
  type        = string
  default     = null
}
