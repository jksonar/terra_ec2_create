terraform {
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