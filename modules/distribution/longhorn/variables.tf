variable "longhorn_enabled" {
  description = "Specifies whether Longhorn should be installed on the Kubernetes cluster. Default is 'false'."
  type        = bool
  default     = false
}

variable "longhorn_host" {
  description = "Specifies the hostname used to expose Longhorn via Ingress (e.g. sslip.io or custom domain). Default is 'null'."
  type        = string
  default     = null
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

variable "node_ips" {
  description = "Specifies the list of node public IP addresses used to prepare Longhorn dependencies on each cluster node. Default is 'null'."
  type        = list(string)
  default     = []
}

variable "ssh_private_key" {
  description = "Specifies the SSH private key content used to connect to cluster nodes for Longhorn dependency preparation. Default is 'true'."
  type        = string
  sensitive   = true
}

variable "ssh_user" {
  description = "Specifies the SSH username used to connect to cluster nodes. Default is 'opensuse'."
  type        = string
  default     = "opensuse"
}

variable "longhorn_hc_version" {
  description = "Specifies the Longhorn Helm chart version to install. Default is null (latest version). Default is 'null'."
  type        = string
  default     = null
}

variable "kubeconfig_path" {
  description = "Path to kubeconfig file used by kubectl. Default is 'null'."
  type        = string
  default     = null
}
