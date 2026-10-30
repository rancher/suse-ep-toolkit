variable "prefix" {
  description = "Specifies the prefix added to the names of all resources. Default is 'gcp-tf'."
  type        = string
  default     = "eptoolkitinfratest"
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

variable "data_disk_size" {
  description = "Specifies the size of the additional data disks for each VM instance, in GB. Default is '350'."
  type        = number
  default     = 40
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
