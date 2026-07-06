############################### VPC #########################################

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "EKS-VPC"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.2.0.0/16"
}

variable "vpc_availability_zones" {
  description = "Availability Zones for ap-southeast-2 region"
  default     = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
  type        = list(string)
}

variable "vpc_private_subnet_cidrs" {
  description = "Private subnet CIDRS for VPC"
  type        = list(string)
  default     = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
}

variable "vpc_private_subnet_names" {
  description = "Names of Private subnets for VPC"
  type        = list(string)
  default     = ["eks-private-2a", "eks-private-2b", "eks-private-2c"]
}

variable "vpc_public_subnet_cidrs" {
  description = "Public subnet CIDRS for VPC"
  type        = list(string)
  default     = ["10.2.4.0/24", "10.2.5.0/24", "10.2.6.0/24"]
}

variable "vpc_public_subnet_names" {
  description = "Names of Public subnets for VPC"
  type        = list(string)
  default     = ["eks-public-2a", "eks-public-2b", "eks-public-2c"]
}

variable "vpc_tags" {
  description = "Tags to apply to resources created by VPC module"
  type        = map(string)
  default = {
    Terraform = "true"
    Account   = "EKS"
  }
}

data "aws_vpc" "eks_vpc" {
  filter {
    name   = "tag:Name"
    values = ["${var.account}-VPC"]
  }
}

data "aws_subnet" "eks_subnet_private_2a" {
  vpc_id = data.aws_vpc.eks_vpc.id

  filter {
    name   = "tag:Name"
    values = ["${var.account_lowercase}-private-2a"]
  }
}

data "aws_subnet" "eks_subnet_private_2b" {
  vpc_id = data.aws_vpc.eks_vpc.id

  filter {
    name   = "tag:Name"
    values = ["${var.account_lowercase}-private-2b"]
  }
}

variable "env" {
  description = "Name of the Environment"
  type        = string
  default     = "Dev"
}

variable "amis" {
  type = map(string)
  default = {
    "AmazonLinux2" = "ami-0099823645f06b6a1"
    "Centos"       = "ami-05f50d9ec7e4c3b02"
  }
}

variable "account" {
  description = "Name of the Account"
  type        = string
  default     = "EKS"
}

variable "account_id" {
  description = "ID of the account"
  type        = string
  default     = "865983312994"
}

variable "account_lowercase" {
  description = "Name of the Account in Lowercase"
  type        = string
  default     = "eks-dev"
}

variable "region" {
  description = "Region of the resource"
  type        = string
  default     = "ap-southeast-2"
}

############################### VPC EKS #########################################
 
variable "seperate_vpc_eks" {
  description = "Boolean to determine whether to create separate VPC for EKS Cluster"
  default     = "false"
  type        = bool
}

variable "vpc_eks_name" {
  description = "Name of the VPC"
  type        = string
  default     = "EKS-VPC"
}

variable "eks_cluster_name" {
  description = "Name of the VPC"
  type        = string
  default     = "EKS-CLUSTER"
}

variable "vpc_eks_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.7.0.0/16"
}

variable "vpc_eks_private_subnet_cidrs" {
  description = "Private subnet CIDRS for VPC"
  type        = list(string)
  default     = []
}

variable "vpc_eks_private_subnet_names" {
  description = "Names of Private subnets for VPC"
  type        = list(string)
  default     = []
}

variable "vpc_eks_public_subnet_cidrs" {
  description = "Public subnet CIDRS for VPC"
  type        = list(string)
  default     = []
}

variable "vpc_eks_public_subnet_names" {
  description = "Names of Public subnets for VPC"
  type        = list(string)
  default     = []
}

variable "vpc_eks_tags" {
  description = "Tags to apply to resources created by VPC module"
  type        = map(string)
  default = {
    Terraform = "true"
    Account   = "EKS-CLUSTER"
  }
}