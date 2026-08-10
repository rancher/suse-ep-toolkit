variable "prefix" {
  description = "Specifies the prefix added to the names of all resources. Default is 'gcp-tf'."
  type        = string
  default     = "gcp-tf"
  validation {
    condition     = can(regex("^[a-z0-9\\-.]+$", var.prefix))
    error_message = "A lowercase RFC 1123 subdomain must consist of lower case alphanumeric characters, '-' or '.'."
  }
}

variable "region" {
  description = "Specifies the GCP region used for all resources. Default is 'europe-west1'."
  type        = string
  default     = "europe-west1"
  validation {
    condition = contains([
      "asia-east1",
      "asia-east2",
      "asia-northeast1",
      "asia-northeast2",
      "asia-northeast3",
      "asia-south1",
      "asia-south2",
      "asia-southeast1",
      "asia-southeast2",
      "australia-southeast1",
      "australia-southeast2",
      "europe-central2",
      "europe-north1",
      "europe-southwest1",
      "europe-west1",
      "europe-west2",
      "europe-west3",
      "europe-west4",
      "europe-west6",
      "europe-west8",
      "europe-west9",
      "europe-west10",
      "europe-west12",
      "me-central1",
      "me-central2",
      "me-west1",
      "northamerica-northeast1",
      "northamerica-northeast2",
      "southamerica-east1",
      "southamerica-west1",
      "us-central1",
      "us-east1",
      "us-east4",
      "us-east5",
      "us-south1",
      "us-west1",
      "us-west2",
      "us-west3",
      "us-west4"
    ], var.region)
    error_message = "Invalid GCP Region specified."
  }
}

variable "zone" {
  description = "Specifies the GCP zone where the instances will be deployed. If null, a zone in the region will be randomly chosen."
  type        = string
  default     = null
}

variable "ssh_public_key_content" {
  description = "Specifies the public SSH key content. Default is 'null'."
  type        = string
  default     = null
}

variable "instance_count" {
  description = "Specifies the number of GCP Compute Engine instances to create. Default is '1'."
  type        = number
  default     = 1
}

variable "spot_instance" {
  description = "Specifies whether the instances should be Spot (preemptible) VMs. Default is 'true'."
  type        = bool
  default     = true
}

variable "instance_type" {
  description = "Specifies the name of a GCP machine type. Default is 'n2-standard-8'."
  type        = string
  default     = "n2-standard-8"
}

variable "ami_id" {
  description = "Specifies the image family, self_link or name of the OS image. Default is empty."
  type        = string
  default     = ""
}

variable "os_disk_type" {
  description = "Specifies the type of the boot disk ('pd-standard', 'pd-balanced', or 'pd-ssd'). Default is 'pd-ssd'."
  type        = string
  default     = "pd-ssd"
}

variable "os_disk_size" {
  description = "Specifies the size of the boot disk attached to each node, in GB. Default is '100'."
  type        = number
  default     = 100
}

variable "data_disk_count" {
  description = "Specifies the number of additional data disks to attach to each VM instance. Default is '1'."
  type        = number
  default     = 1
}

variable "data_disk_type" {
  description = "Specifies the type of the additional data disks ('pd-standard', 'pd-balanced', or 'pd-ssd'). Default is 'pd-ssd'."
  type        = string
  default     = "pd-ssd"
}

variable "data_disk_size" {
  description = "Specifies the size of the additional data disks for each VM instance, in GB. Default is '350'."
  type        = number
  default     = 350
}

variable "user_data" {
  description = "Specifies cloud-init user_data used to bootstrap the GCP Compute Instance. Default is 'null'."
  type        = string
  default     = null
}

variable "ip_cidr_range" {
  description = "Specifies the range of private IPs available for the Subnet and VPC. Default is '10.10.0.0/24'."
  type        = string
  default     = "10.10.0.0/24"
}

variable "create_network_resources" {
  description = "Specifies whether to create the VPC networking resources (VPC, Subnet, Firewall rules). Default is 'false'."
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "Specifies the name or self_link of an existing VPC network. Default is 'null'."
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Specifies the name or self_link of an existing GCP Subnet where the instances will be deployed. Default is 'null'."
  type        = string
  default     = null
}
