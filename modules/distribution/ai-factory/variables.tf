variable "ai_factory_enabled" {
  description = "Specifies whether Rancher should be installed on the Kubernetes cluster. Default is 'false'."
  type        = bool
  default     = false
}

variable "ai_factory_hc_version" {
  description = "Specifies the Rancher Helm chart version to install. Default is null (latest version). Default is 'null'."
  type        = string
  default     = null
}

variable "app_collection_username" {
  description = "Specifies the SUSE AppCo username. Default is 'null'."
  type        = string
  default     = null
}

variable "app_collection_password" {
  description = "Specifies the SUSE AppCo password. Default is 'null'."
  type        = string
  default     = null
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
