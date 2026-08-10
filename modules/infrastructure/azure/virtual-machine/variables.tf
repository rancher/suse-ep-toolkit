variable "prefix" {
  description = "Specifies the prefix added to the names of all resources. Default is 'azure-tf'."
  type        = string
  default     = "azure-tf"
  validation {
    condition     = can(regex("^[a-z0-9\\-.]+$", var.prefix))
    error_message = "a lowercase RFC 1123 subdomain must consist of lower case alphanumeric characters, '-' or '.'"
  }
}

variable "resource_group" {
  description = "Specifies the resource group where resources will be allocated. Default is 'null'."
  type = object({
    name     = string
    location = string
  })
  default = null
}

variable "region" {
  description = "Specifies the Azure region used for all resources. Default is 'westeurope'."
  type        = string
  default     = "westeurope"
  validation {
    condition = contains([
      "australiacentral",
      "australiacentral2",
      "australiaeast",
      "australiasoutheast",
      "austriaeast",
      "brazilsouth",
      "brazilsoutheast",
      "canadacentral",
      "canadaeast",
      "centralindia",
      "centralus",
      "centraluseuap",
      "chilecentral",
      "eastasia",
      "eastus",
      "eastus2",
      "eastus2euap",
      "francecentral",
      "francesouth",
      "germanynorth",
      "germanywestcentral",
      "indonesiacentral",
      "israelcentral",
      "italynorth",
      "japaneast",
      "japanwest",
      "jioindiacentral",
      "jioindiawest",
      "koreacentral",
      "koreasouth",
      "malaysiasouth",
      "malaysiawest",
      "mexicocentral",
      "northcentralus",
      "northeurope",
      "norwayeast",
      "norwaywest",
      "polandcentral",
      "southafricanorth",
      "southafricawest",
      "southcentralus",
      "southcentralusstg",
      "southeastasia",
      "southindia",
      "spaincentral",
      "swedencentral",
      "switzerlandnorth",
      "switzerlandwest",
      "taiwannorth",
      "uaenorth",
      "uksouth",
      "ukwest",
      "westcentralus",
      "westeurope",
      "westus",
      "westus2",
      "westus3"
    ], var.region)
    error_message = "Invalid Region specified."
  }
}

variable "ssh_public_key_content" {
  description = "Specifies the public SSH key content. Default is 'null'."
  type        = string
  default     = null
}

variable "instance_count" {
  description = "Specifies the number of Azure Virtual Machines to create. Default is '1'."
  type        = number
  default     = 1
}

variable "spot_instance" {
  description = "Specifies whether the instances should be Spot (preemptible) VMs. Default is 'true'."
  type        = bool
  default     = true
}

variable "instance_type" {
  description = "Specifies the name of an Azure Virtual Machine type. Default is 'Standard_D8s_v5'. https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/general-purpose/dsv5-series"
  type        = string
  default     = "Standard_D8s_v5"
  validation {
    condition = contains([
      "Standard_D2s_v5",
      "Standard_D4s_v5",
      "Standard_D8s_v5",
      "Standard_D16s_v5",
      "Standard_D32s_v5",
      "Standard_D48s_v5",
      "Standard_D64s_v5",
      "Standard_D96s_v5"
    ], var.instance_type)
    error_message = "Instance type not allowed. Must be from one of the dsv5 series https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/general-purpose/dsv5-series"
  }
}

variable "ami_id" {
  description = "Specifies the ID of the custom OS image used to provision all RKE2 cluster Azure Virtual Machines. Default is empty."
  type        = string
  default     = ""
}

variable "os_disk_type" {
  description = "Specifies the type of the disk attached to each node ('Standard_LRS, 'StandardSSD_LRS', 'Premium_LRS' or 'UltraSSD_LRS'). Default is 'StandardSSD_LRS'."
  type        = string
  default     = "StandardSSD_LRS"
}

variable "os_disk_size" {
  description = "Specifies the size of the disk attached to each node, in GB. Default is '100'."
  type        = string
  default     = "100"
}

variable "data_disk_count" {
  description = "Specifies the number of additional data disks to attach to each VM instance. Default is '1'."
  type        = number
  default     = 1
}

variable "data_disk_type" {
  description = "Specifies the type of the disks attached to each node ('Standard_LRS, 'StandardSSD_LRS', 'Premium_LRS' or 'UltraSSD_LRS'). Default is 'Premium_LRS'."
  type        = string
  default     = "Premium_LRS"
}

variable "data_disk_size" {
  description = "Specifies the size of the additional data disks for each VM instance, in GB. Default is '350'."
  type        = number
  default     = 350
}

variable "user_data" {
  description = "Specifies cloud-init user_data used to bootstrap the Azure Virtual Machine. Default is 'null'."
  type        = string
  default     = null
}

variable "ip_cidr_range" {
  description = "Specifies the range of private IPs available for the Azure Subnet and VNet. Default is '10.10.0.0'."
  type        = string
  default     = "10.10.0.0/24"
}

variable "create_network_resources" {
  description = "Specifies whether to create the VNet networking resources (security group and related resources). Default is 'false'."
  type        = bool
  default     = false
}

variable "subnet_id" {
  description = "Specifies the ID of an existing Azure subnet where the Virtual Machines instances will be deployed. Default is 'null'."
  type        = string
  default     = null
}

variable "nsg_id" {
  description = "Specifies the ID of an existing Azure Network Security Group where the Virtual Machines instances will be deployed. Default is 'null'."
  type        = string
  default     = null
}
