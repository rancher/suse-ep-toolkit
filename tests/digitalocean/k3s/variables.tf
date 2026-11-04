variable "prefix" {
  description = "Specifies the prefix added to the names of all resources. Default is 'eptoolkit-k3s-test'."
  type        = string
  default     = "eptoolkit-k3s-test"
}

variable "do_token" {
  description = "DigitalOcean API token used to deploy the infrastructure. Default is 'null'."
  type        = string
  default     = null
}

variable "instance_type" {
  description = "Specifies the name of the DigitalOcean Droplet type. Default is 'g-16vcpu-64gb'."
  type        = string
  default     = "s-4vcpu-8gb"
}

variable "data_disk_size" {
  description = "Specifies the size of the additional data disks attached to the Droplet, in GB. Default is '350'."
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

variable "k3s_version" {
  description = "Specifies the K3s version to install. Default is 'v1.36.5+k3s1'."
  type        = string
  default     = "v1.36.5+k3s1"
  validation {
    condition     = can(regex("^v.*$", var.k3s_version))
    error_message = "The K3s version must start with 'v'."
  }
}

variable "k3s_ingress" {
  description = "Specifies the ingress controller to deploy. Allowed values are 'traefik', 'nginx', or 'none'. Default is 'traefik'."
  type        = string
  default     = "traefik"
  validation {
    condition     = contains(["traefik", "nginx", "none"], var.k3s_ingress)
    error_message = "Invalid ingress controller. Allowed values are 'traefik', 'nginx', or 'none'."
  }
}
