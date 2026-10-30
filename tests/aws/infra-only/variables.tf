variable "prefix" {
  description = "Specifies the prefix added to the names of all resources. Default is 'eptoolkitinfratest'."
  type        = string
  default     = "eptoolkitinfratest"
}

variable "ami_id" {
  description = "Specifies the AWS AMI ID used to provision the VMs. If left empty, our custom OS image will be used. If specified, must be an OpenSUSE leap 15-6 or 16-0 AMI. Default is empty."
  type        = string
  default     = ""
}

variable "data_disk_size" {
  description = "Specifies the size of the additional data disks attached to the AWS EC2 instance, in GB. Default is '40'."
  type        = number
  default     = 40
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
