terraform {
  required_providers {
    ssh = {
      source  = "loafoe/ssh"
      version = "2.7.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.4.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.3.0"
    }
    rancher2 = {
      source  = "rancher/rancher2"
      version = "14.1.0"
    }
  }
}
