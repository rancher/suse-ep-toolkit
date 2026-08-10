variable "neuvector_enabled" {
  description = "Specifies whether NeuVector should be installed on the Kubernetes cluster. Default is 'false'."
  type        = bool
  default     = false
}

variable "neuvector_host" {
  description = "Specifies the hostname used to expose NeuVector via Ingress (e.g. sslip.io or custom domain). Default is 'null'."
  type        = string
  default     = null
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

variable "longhorn_enabled" {
  description = "Specifies whether Longhorn should be installed on the Kubernetes cluster. Default is 'false'."
  type        = bool
  default     = false
}

variable "kubeconfig_path" {
  description = "Path to kubeconfig file used by kubectl. Default is 'null'."
  type        = string
  default     = null
}
