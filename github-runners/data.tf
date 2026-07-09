data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["EKS-VPC"]
  }
}
