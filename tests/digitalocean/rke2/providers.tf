terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.106.0"
    }
    ssh = {
      source  = "loafoe/ssh"
      version = "2.9.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.5.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}
