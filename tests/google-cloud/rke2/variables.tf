variable "prefix" {
  description = "Specifies the prefix added to the names of all resources. Default is 'eptoolkit-rke2-test'."
  type        = string
  default     = "eptoolkit-rke2-test"
}

variable "project_id" {
  description = "Specifies the GCP Project ID that will contain all created resources. Default is empty."
  type        = string
  default     = ""
}

variable "zone" {
  description = "Specifies the GCP zone letter (e.g., 'a', 'b', 'c') where the instances will be deployed. If null, a zone in the region will be randomly chosen. Default is 'null'."
  type        = string
  default     = null
  validation {
    condition     = var.zone == null ? true : can(regex("^[a-z]$", var.zone))
    error_message = "The zone must be a single lowercase letter (e.g., 'a', 'b', 'c')."
  }
}

variable "instance_type" {
  description = "Specifies the name of a GCP machine type. Default is 'n2-standard-8'."
  type        = string
  default     = "n2-standard-8"
}

variable "data_disk_size" {
  description = "Specifies the size of the additional data disks for each VM instance, in GB. Default is '150'."
  type        = number
  default     = 150
}

variable "ami_id" {
  description = "Specifies the image family, self_link, or name of the custom OS image. Must start with 'opensuse-leap-16' and end with 'x86-64'. Default is empty."
  type        = string
  default     = ""
  validation {
    condition = (
      var.ami_id == "" ||
      can(regex("^opensuse-leap-16.*x86-64$", var.ami_id))
    )
    error_message = "When specified, ami_id must start with 'opensuse-leap-16' and end with 'x86-64' (e.g. opensuse-leap-16-0-v20260629-x86-64)."
  }
}

variable "public_ip_source_addresses" {
  description = "Specifies a list of CIDR blocks allowed to access port 22 (SSH). Default is an empty list (no restrictions defined at variable level)."
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for cidr in var.public_ip_source_addresses :
      can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}\\/([0-9]|[12][0-9]|3[0-2])$", cidr))
    ])
    error_message = "Each value must be in CIDR format (A.B.C.D/N), e.g. [\"203.0.113.10/32\", \"198.51.100.0/24\"]."
  }
}

variable "rke2_version" {
  description = "Specifies the RKE2 version to install. Default is 'v1.35.4+rke2r1'."
  type        = string
  default     = "v1.35.4+rke2r1"
  validation {
    condition     = can(regex("^v.*$", var.rke2_version))
    error_message = "The RKE2 version must start with 'v'."
  }
}

variable "rke2_ingress" {
  description = "Specifies the ingress controller to deploy. Allowed values are 'traefik', 'nginx', or 'none'. Default is 'traefik'."
  type        = string
  default     = "traefik"
  validation {
    condition     = contains(["traefik", "nginx", "none"], var.rke2_ingress)
    error_message = "Invalid ingress controller. Allowed values are 'traefik', 'nginx', or 'none'."
  }
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
