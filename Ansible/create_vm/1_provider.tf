terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.25.0"
    }
  }
}


provider "aws" {
  # Configuration options
  region     = "us-east-1"
  access_key = ""
  secret_key = ""

}