variable "suse_ai_enabled" {
  description = "Specifies whether suse ai stack with gpu should be installed on the Kubernetes cluster. Default is 'false'."
  type        = bool
  default     = false
}

variable "suse_ai_gpu" {
  description = "Enable GPU support for SUSE AI. If true, requires a GPU-capable instance_type. Default is 'false'"
  type        = bool
  default     = false
}

variable "node_ips" {
  description = "Specifies the list of node public IP addresses used to prepare Longhorn dependencies on each cluster node. Default is 'null'."
  type        = list(string)
  default     = []
}

variable "kubeconfig_path" {
  description = "Path to kubeconfig file used by kubectl. Default is 'null'."
  type        = string
  default     = null
}

variable "ssh_private_key" {
  description = "Specifies the SSH private key content used to connect to cluster nodes for Longhorn dependency preparation. Default is 'true'."
  type        = string
  sensitive   = true
}

variable "ssh_username" {
  description = "Specifies the SSH username used to connect to cluster nodes. Default is 'opensuse'."
  type        = string
  default     = "opensuse"
}

variable "milvus_hc_version" {
  description = "Specifies the milvus Helm chart version to install. Default is null (latest version)."
  type        = string
  default     = "4.2.2"
}

variable "ollama_hc_version" {
  description = "Specifies the ollama Helm chart version to install. Default is null (latest version)."
  type        = string
  default     = null
}

variable "openwebui_hc_version" {
  description = "Specifies the ollama Helm chart version to install. Default is null (latest version)."
  type        = string
  default     = null
}

variable "app_collection_username" {
  description = "Specifies the SUSE AppCo username. Default is 'null'."
  type        = string
  default     = null
}

variable "app_collection_password" {
  description = "Specifies the SUSE AppCo password. Default is 'null'."
  type        = string
  default     = null
}

variable "openwebui_host" {
  description = "Specifies the hostname used to expose OpenWebUI via Ingress (e.g. sslip.io or custom domain). Default is 'null'."
  type        = string
  default     = null
}