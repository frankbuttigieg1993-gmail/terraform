
############################### Public Route Tables #########################################

resource "aws_route_table" "public" {
  vpc_id = module.vpc.vpc_id
  tags = {
    Name = "${var.account} - Public Route Table"
  }
}

resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  depends_on             = [aws_route_table.public]
  gateway_id             = aws_internet_gateway.internetgateway.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.vpc_public_subnet_names)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

############################### Private Route Tables #########################################

resource "aws_route_table" "private" {
  vpc_id = module.vpc.vpc_id
  tags = {
    Name = "${var.account} - Private Route Table"
  }
}

resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  depends_on             = [aws_route_table.private]
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.vpc_private_subnet_names)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

############################### EKS Private Route Tables #########################################

resource "aws_route_table" "eks_private" {
  count  = var.seperate_vpc_eks ? 1 : 0
  vpc_id = module.vpc_eks[0].vpc_id
  tags = {
    Name = "${var.eks_cluster_name} - Private Route Table"
  }
}

resource "aws_route" "eks_private_nat" {
  count                  = var.seperate_vpc_eks ? 1 : 0
  route_table_id         = aws_route_table.eks_private[0].id
  destination_cidr_block = "0.0.0.0/0"
  depends_on             = [aws_route_table.eks_private]
  nat_gateway_id         = aws_nat_gateway.vpc_eks_nat_gateway[0].id
}

resource "aws_route_table_association" "eks_private" {
  count          = length(var.vpc_eks_private_subnet_names)
  subnet_id      = element(aws_subnet.vpc_eks_private.*.id, count.index)
  route_table_id = aws_route_table.eks_private[0].id
}

############################### EKS Public Route Tables #########################################

resource "aws_route_table" "eks_public" {
  count  = var.seperate_vpc_eks ? 1 : 0
  vpc_id = module.vpc_eks[0].vpc_id
  tags = {
    Name = "${var.eks_cluster_name} - Public Route Table"
  }
}

resource "aws_route" "eks_public_igw" {
  count                  = var.seperate_vpc_eks ? 1 : 0
  route_table_id         = aws_route_table.eks_public[0].id
  destination_cidr_block = "0.0.0.0/0"
  depends_on             = [aws_route_table.eks_public]
  gateway_id             = aws_internet_gateway.vpc_eks_internetgateway[0].id
}

resource "aws_route_table_association" "eks_public" {
  count          = length(var.vpc_eks_public_subnet_names)
  subnet_id      = element(aws_subnet.vpc_eks_public.*.id, count.index)
  route_table_id = aws_route_table.eks_public[0].id
}
