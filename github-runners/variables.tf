variable "amis" {
  type = map(string)
  default = {
    "AmazonLinux2" = "ami-0099823645f06b6a1"
    "Centos" = "ami-05f50d9ec7e4c3b02"
  }
}

variable "aws_region" {
  default = "ap-southeast-2"
}

variable "instance_name" {
  default = "aws_github_runner_slave_AMI_creator"
}

variable "account" {
  description = "Name of the Account"
  type        = string
  default     = "aws"
}
