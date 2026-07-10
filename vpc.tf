module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  version              = "2.21.0"
  name                 = var.vpc_name
  cidr                 = var.vpc_cidr
  azs                  = var.vpc_availability_zones
  enable_nat_gateway   = true
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = var.vpc_tags
}

############################### NAT and Internet Gateway #########################################
resource "aws_internet_gateway" "internetgateway" {
  vpc_id = module.vpc.vpc_id
  tags = {
    Account = var.account
    Name    = "${var.account} - Internet Gateway"
  }
}

resource "aws_eip" "nat_gateway" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.public.2.id
  depends_on    = [aws_internet_gateway.internetgateway]
  tags = {
    Name = "${var.account} - NAT Gateway"
  }
}

############################### EKS VPC, NAT and Internet Gateway #########################################

module "vpc_eks" {
  count                = var.seperate_vpc_eks ? 1 : 0
  source               = "terraform-aws-modules/vpc/aws"
  version              = "2.21.0"
  name                 = var.vpc_eks_name
  cidr                 = var.vpc_eks_cidr
  azs                  = var.vpc_availability_zones
  enable_nat_gateway   = true
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = var.vpc_eks_tags
}

resource "aws_internet_gateway" "vpc_eks_internetgateway" {
  count  = var.seperate_vpc_eks ? 1 : 0
  vpc_id = module.vpc_eks[0].vpc_id
  tags = {
    Account = var.account
    Name    = "${var.eks_cluster_name} - Internet Gateway"
  }
}

resource "aws_eip" "vpc_eks_nat_gateway" {
  count = var.seperate_vpc_eks ? 1 : 0
  vpc   = true
}

resource "aws_nat_gateway" "vpc_eks_nat_gateway" {
  count         = var.seperate_vpc_eks ? 1 : 0
  allocation_id = aws_eip.vpc_eks_nat_gateway[0].id
  subnet_id     = aws_subnet.vpc_eks_public.2.id
  depends_on    = [aws_internet_gateway.vpc_eks_internetgateway]
  tags = {
    Name = "${var.eks_cluster_name} - NAT Gateway"
  }
}
