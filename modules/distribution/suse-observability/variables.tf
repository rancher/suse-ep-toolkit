variable "suse_observability_enabled" {
  description = "Specifies whether SUSE Observability should be installed on the Kubernetes cluster. Default is 'false'."
  type        = bool
  default     = false
}

variable "suse_observability_host" {
  description = "Specifies the hostname used to expose SUSE Observability via Ingress (e.g. sslip.io or custom domain). Default is 'null'."
  type        = string
  default     = null
}

variable "suse_observability_otlp_host" {
  description = "Specifies the hostname used to expose SUSE Observability OTLP endpoint via Ingress (e.g. sslip.io or custom domain). Default is 'null'."
  type        = string
  default     = null
}

variable "suse_observability_otlp_http_host" {
  description = "Specifies the hostname used to expose SUSE Observability OTLP HTTP endpoint via Ingress (e.g. sslip.io or custom domain). Default is 'null'."
  type        = string
  default     = null
}

variable "suse_observability_hc_version" {
  description = "Specifies the SUSE Observability Helm chart version to install. Default is 'null' (latest version)."
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
  default     = null
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

variable "kubeconfig_path" {
  description = "Path to kubeconfig file used by kubectl. Default is 'null'."
  type        = string
  default     = null
}

variable "rancher_enabled" {
  description = "Specifies whether Rancher should be installed on the Kubernetes cluster. Default is 'false'."
  type        = bool
  default     = false
}

variable "rancher_host" {
  description = "Specifies the hostname used to expose Rancher via Ingress. Default is 'null'."
  type        = string
  default     = null
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
