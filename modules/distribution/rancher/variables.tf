variable "rancher_enabled" {
  description = "Specifies whether Rancher should be installed on the Kubernetes cluster. Default is 'false'."
  type        = bool
  default     = false
}

variable "rancher_hc_version" {
  description = "Specifies the Rancher Helm chart version to install. Default is null (latest version). Default is 'null'."
  type        = string
  default     = null
}

variable "rancher_host" {
  description = "Specifies the hostname used to expose Rancher via Ingress. Default is 'null'."
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

variable "rancher_tls_source" {
  description = "Specifies the TLS certificate source used by Rancher. Default is 'letsEncrypt'."
  type        = string
  default     = "letsEncrypt"
}

variable "kubeconfig_path" {
  description = "Path to kubeconfig file used by kubectl. Default is 'null'."
  type        = string
  default     = null
}
