variable "prefix" {
  description = "Specifies the prefix added to the names of all resources. Default is 'azure-tf'."
  type        = string
  default     = "eptoolkitinfratest"
}

variable "subscription_id" {
  description = "Specifies the Azure Subscription ID that will contain all created resources. Default is empty."
  type        = string
  default     = ""
}

variable "zone" {
  description = "Specifies the Azure zone where resources will be allocated. Default is '1'."
  type        = number
  default     = 1
}

variable "spot_instance" {
  description = "Specifies whether the instances should be Spot (preemptible) VMs. Default is 'true'."
  type        = bool
  default     = false
}

variable "instance_type" {
  description = "Specifies the name of an Azure Virtual Machine type. Default is 'Standard_D8s_v5'. https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/general-purpose/dsv5-series"
  type        = string
  default     = "Standard_D4s_v5"
  validation {
    condition = contains([
      "Standard_D2s_v5",
      "Standard_D4s_v5",
      "Standard_D8s_v5",
      "Standard_D16s_v5",
      "Standard_D32s_v5",
      "Standard_D48s_v5",
      "Standard_D64s_v5",
      "Standard_D96s_v5",
      "Standard_NC40ads_H100_v5",
      "Standard_NC16as_T4_v3"
    ], var.instance_type)
    error_message = "Instance type not allowed. Must be from dsv5 series https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/general-purpose/dsv5-series"
  }
}

variable "image_publisher" {
  description = "Specifies the publisher of the Marketplace image used when ami_id is not provided. Default is 'null'."
  type        = string
  default     = null
}

variable "image_offer" {
  description = "Specifies the offer of the Marketplace image used when ami_id is not provided. Default is 'null'."
  type        = string
  default     = null
}

variable "image_sku" {
  description = "Specifies the SKU of the Marketplace image used when ami_id is not provided. Default is 'null'."
  type        = string
  default     = null
}

variable "image_version" {
  description = "Specifies the version of the Marketplace image used when ami_id is not provided. Default is 'null'."
  type        = string
  default     = null
}

variable "data_disk_size" {
  description = "Specifies the size of the additional data disks for each VM instance, in GB. Default is '500'."
  type        = number
  default     = 40
}

variable "disk_throughput_mbps_read_write" {
  description = "Specifies the amount of disk throughput on the data disk"
  type        = number
  default     = 125
}

variable "disk_iops_read_write" {
  description = "Specifies the amount of disk IOPS on the data disk"
  type        = number
  default     = 3000
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
