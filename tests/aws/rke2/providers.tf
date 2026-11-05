terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.71.0"
    }
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
      version = "3.1.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }
  }
}

provider "aws" {
  region = local.region
}
