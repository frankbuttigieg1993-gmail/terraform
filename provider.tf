# Define the provider
# Note if the local host has different profile for aws accounts, 
# it should be provided in the "profile" parameters

provider "aws" {
  region = "ap-southeast-2"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.56.0"
    }
  }
}
