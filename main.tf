terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    volterra = {
      source  = "volterraedge/volterra"
      version = "0.11.9"
    }
  }
}