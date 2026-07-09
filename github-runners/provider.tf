# Define the provider
# Note if the local host has different profile for aws accounts, 
# it should be provided in the "profile" parameters

provider "aws" {
  region = "ap-southeast-2"
  profile = "default"
  version = "3.74.0"
}
