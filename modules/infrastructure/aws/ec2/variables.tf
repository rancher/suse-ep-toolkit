variable "prefix" {
  description = "Specifies the prefix added to the names of all resources. Default is 'aws-tf'."
  type        = string
  default     = "aws-tf"
}

variable "region" {
  description = "Specifies the AWS region used for all resources. Default is 'us-east-1'."
  type        = string
  default     = "us-east-1"
  validation {
    condition = contains([
      "ap-south-2",
      "ap-south-1",
      "eu-west-1",
      "eu-west-2",
      "eu-west-3",
      "eu-north-1",
      "eu-south-1",
      "eu-south-2",
      "eu-central-2",
      "ap-northeast-2",
      "ap-northeast-1",
      "ca-central-1",
      "sa-east-1",
      "ap-southeast-1",
      "ap-southeast-2",
      "eu-central-1",
      "us-east-1",
      "us-east-2",
      "us-west-1",
      "us-west-2"
    ], var.region)
    error_message = "Invalid Region specified."
  }
}

variable "ssh_key_name" {
  description = "Specifies the name of the AWS EC2 Key Pair used to access the instances through SSH. Default is 'null'."
  type        = string
  default     = null
}

variable "ssh_key_content" {
  description = "Specifies the public SSH key content used to create the AWS EC2 Key Pair. Default is 'null'."
  type        = string
  default     = null
}

variable "instance_count" {
  description = "Specifies the number of EC2 instances to create. Default is 1."
  type        = number
  default     = 1
}

variable "spot_instance" {
  description = "Specifies whether the instances should be Spot (preemptible) VMs. Default is 'true'."
  type        = bool
  default     = true
}

variable "instance_type" {
  description = "Specifies the name of an AWS EC2 instance. Default is 'm8i.large'."
  type        = string
  default     = "m8i.large"
}

variable "data_disk_count" {
  description = "Specifies the number of additional data disks to attach to each VM instance. Default is 1."
  type        = number
  default     = 1
}

variable "data_disk_size" {
  description = "Specifies the size of each additional data disks attached to the EC2 instance, in GB. Default is '350'."
  type        = number
  default     = 350
}

variable "ami_id" {
  description = "Specifies the ID of the custom OS image used to provision all RKE2 cluster EC2 instances. Default is empty."
  type        = string
  default     = ""
}

variable "user_data" {
  description = "Specifies cloud-init user_data used to bootstrap the EC2 instance. Default is 'null'."
  type        = string
  default     = null
}

variable "ip_cidr_range" {
  description = "Specifies the range of private IPs available for the AWS Subnet and VPC. Default is '10.10.0.0'."
  type        = string
  default     = "10.0.0.0"
}

variable "create_network_resources" {
  description = "Specifies whether to create the VPC networking resources (security group and related resources). Default is 'false'."
  type        = bool
  default     = false
}

variable "subnet_id" {
  description = "Specifies the ID of an existing AWS subnet where the EC2 instances will be deployed. Default is 'null'."
  type        = string
  default     = null
}

variable "security_group_id" {
  description = "Specifies the ID of an existing AWS security group to associate with the EC2 instances. Default is 'null'."
  type        = string
  default     = null
}
