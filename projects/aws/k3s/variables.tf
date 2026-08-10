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

variable "instance_count" {
  description = "Specifies the number of EC2 instances (nodes) to create for the k3s cluster. This value defines the total cluster size, including the first server node, additional server nodes (if count <= 3), and worker nodes (if count > 3). Default is '1'."
  type        = number
  default     = 1
  validation {
    condition     = var.instance_count == 1 || var.instance_count >= 3
    error_message = "instance_count must be either 1 (single-node cluster) or >= 3 (multi-node k3s cluster)."
  }
}

variable "spot_instance" {
  description = "Specifies whether the instances should be Spot (preemptible) VMs. Default is 'true'."
  type        = bool
  default     = true
}

variable "instance_type" {
  description = "Specifies the name of the AWS EC2 instance type. Default is 'm8i.4xlarge'."
  type        = string
  default     = "m8i.4xlarge"
}

variable "data_disk_size" {
  description = "Specifies the size of the additional data disks attached to the AWS EC2 instance, in GB. Default is '350'."
  type        = number
  default     = 350
}

variable "node_role" {
  description = "Specifies the k3s node role for this instance. Valid values are 'server' or 'agent'. The role determines whether the node participates in the control plane/etcd cluster ('server') or joins as a worker node ('agent'). Default is 'agent'."
  type        = string
  default     = "agent"
  validation {
    condition     = contains(["server", "agent"], var.node_role)
    error_message = "Invalid node_role. Allowed values are 'server' or 'agent'."
  }
}

variable "k3s_version" {
  description = "Specifies the K3s version to install. Default is 'v1.33.5+k3s1'."
  type        = string
  default     = "v1.33.5+k3s1"
  validation {
    condition     = can(regex("^v.*$", var.k3s_version))
    error_message = "The K3s version must start with 'v'."
  }
}

variable "longhorn_enabled" {
  description = "Specifies whether Longhorn should be installed on the Kubernetes cluster. Default is 'false'."
  type        = bool
  default     = false
  validation {
    condition = (
      var.longhorn_enabled == false ||
      var.instance_count >= 3
    )
    error_message = "When longhorn_enabled is true, instance_count must be at least 3."
  }
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
  validation {
    condition = (
      var.suse_observability_enabled == false ||
      var.instance_count >= 3
    )
    error_message = "When suse_observability_enabled is true, instance_count must be at least 3."
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

variable "neuvector_enabled" {
  description = "Specifies whether NeuVector should be installed on the Kubernetes cluster. Default is 'false'."
  type        = bool
  default     = false
}

variable "neuvector_hc_version" {
  description = "Specifies the NeuVector Helm chart version to install. Default is 'null' (latest version)."
  type        = string
  default     = null
}

variable "neuvector_version" {
  description = "Specifies the NeuVector application version deployed by the Helm chart. Default is empty (chart default version)."
  type        = string
  default     = ""
  validation {
    condition = (
      var.neuvector_version == "" ||
      can(regex("^\\d+\\.\\d+\\.\\d+$", var.neuvector_version))
    )
    error_message = "neuvector_version must use semantic version format 'x.y.z' (e.g. 5.5.1 or 5.0.1)."
  }
}

variable "neuvector_admin_password" {
  description = "Specifies the NeuVector administrator password. Must be at least 12 characters and include at least 1 uppercase letter, 1 number, and 1 special character. Default is empty."
  type        = string
  default     = ""
  sensitive   = true
  validation {
    condition = (
      var.neuvector_enabled == false ||
      (
        var.neuvector_admin_password != null &&
        length(var.neuvector_admin_password) >= 12 &&
        can(regex("[A-Z]", var.neuvector_admin_password)) &&
        can(regex("[0-9]", var.neuvector_admin_password)) &&
        can(regex("[^A-Za-z0-9]", var.neuvector_admin_password))
      )
    )
    error_message = "Password must be ≥12 chars, include at least 1 uppercase letter, 1 number, and 1 special character."
  }
}

variable "neuvector_controller_count" {
  description = "Specifies the number of NeuVector controller replicas to deploy. Default is 'null'."
  type        = number
  default     = null
}

variable "neuvector_scanner_count" {
  description = "Specifies the number of NeuVector scanner replicas to deploy. Default is 'null'."
  type        = number
  default     = null
}
