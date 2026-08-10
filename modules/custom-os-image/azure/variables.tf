variable "prefix" {
  description = "Specifies the prefix added to the names of all resources. Default is 'azure-tf'."
  type        = string
  default     = "azure-tf"
}

variable "subscription_id" {
  description = "Specifies the Azure Subscription ID that will contain all created resources. Default is empty."
  type        = string
  default     = ""
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
