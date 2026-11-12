terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.46.2"
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
      version = "3.4.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.3.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
