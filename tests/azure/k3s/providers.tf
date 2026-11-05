terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.81.0"
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

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}
