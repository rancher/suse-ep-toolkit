variable "node_role" {
  description = "Specifies the K3s node role for this instance. Valid values are 'server' or 'agent'. The role determines whether the node participates in the control plane cluster ('server') or joins as a worker node ('agent'). Default is 'agent'."
  type        = string
  default     = "agent"
  validation {
    condition     = contains(["server", "agent"], var.node_role)
    error_message = "Invalid node_role. Allowed values are 'server' or 'agent'."
  }
}

variable "k3s_token" {
  description = "Specifies the shared token used by all nodes to join the K3s cluster. Default is 'null'."
  type        = string
  default     = null
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

variable "server_url" {
  description = "Specifies the URL of the first K3s server node (required for 'server' joining an existing cluster and for 'agent'). Default is 'null'."
  type        = string
  default     = null
}

variable "k3s_config" {
  description = "Specifies additional custom K3s configuration in YAML format. Default is empty."
  type        = string
  default     = ""
}

variable "disable_components" {
  description = "Specifies bundled K3s components to disable. Default is empty."
  type        = list(string)
  default     = []
}

variable "volume_device" {
  description = "Specifies the volume device mounted on the cloud instance. Default is '/dev/sda/'."
  type        = string
  default     = "/dev/sda"
}
