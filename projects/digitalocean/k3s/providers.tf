terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.108.0"
    }
    ssh = {
      source  = "loafoe/ssh"
      version = "2.9.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.6.3"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.3.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}
