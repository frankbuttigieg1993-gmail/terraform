############################### Public Subnets #########################################

resource "aws_subnet" "public" {
  count = length(var.vpc_public_subnet_cidrs)
  vpc_id = module.vpc.vpc_id
  map_public_ip_on_launch = "true"
  cidr_block = var.vpc_public_subnet_cidrs[count.index]
  availability_zone = var.vpc_availability_zones[count.index]
  tags = {
    Name = var.vpc_public_subnet_names[count.index]
  }
}


############################### Private Subnets #########################################

resource "aws_subnet" "private" {
  count = length(var.vpc_private_subnet_cidrs)
  vpc_id = module.vpc.vpc_id
  cidr_block = var.vpc_private_subnet_cidrs[count.index]
  availability_zone = var.vpc_availability_zones[count.index]
  tags = {
    Name = var.vpc_private_subnet_names[count.index]
  }
}

############################### EKS Subnets #########################################

resource "aws_subnet" "vpc_eks_private" {
  count = length(var.vpc_eks_private_subnet_cidrs)
  vpc_id = module.vpc_eks[0].vpc_id
  cidr_block = var.vpc_eks_private_subnet_cidrs[count.index]
  availability_zone = var.vpc_availability_zones[count.index]
  tags = {
    Name = var.vpc_eks_private_subnet_names[count.index]
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_subnet" "vpc_eks_public" {
  count = length(var.vpc_eks_public_subnet_cidrs)
  vpc_id = module.vpc_eks[0].vpc_id
  cidr_block = var.vpc_eks_public_subnet_cidrs[count.index]
  availability_zone = var.vpc_availability_zones[count.index]
  tags = {
    Name = var.vpc_eks_public_subnet_names[count.index]
  }
}
