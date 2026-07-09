terraform {
  backend "s3" {
    bucket  = "terraform-frankbuttigieg1993-github-runners"
    key     = "terraform.tfstate"
    region  = "ap-southeast-2"
    encrypt = true
  }
}
