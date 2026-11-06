terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.46.2"
    }
    ssh = {
      source  = "loafoe/ssh"
      version = "2.7.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.6.3"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = local.region
}
