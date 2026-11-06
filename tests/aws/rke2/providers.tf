terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.71.0"
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

provider "aws" {
  region = local.region
}
