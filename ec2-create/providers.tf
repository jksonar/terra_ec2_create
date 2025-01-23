terraform {
  backend "consul" {
    address      = "127.0.0.1:8500"
    scheme       = "http"
    path         = "terraform/state"
    lock         = true
    access_token = "26d48902-905e-ec83-9a29-e70a40558636"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.34.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
  }
}

provider "aws" {
  alias  = "us"
  region = var.availability_zone
}

provider "aws" {
  region = "ap-south-1"
}