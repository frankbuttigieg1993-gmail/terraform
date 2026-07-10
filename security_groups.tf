####################################################### EKS ALB ##########################################################################

resource "aws_security_group" "EKS_LoadBalancer" {
  name        = "EKS LoadBalancer Security Group"
  description = " EKS LoadBalancer Security Group"
  vpc_id      = module.vpc.vpc_id
  tags = {
    Name = "EKS LoadBalancer Security Group"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "HTTPS_PublicInternet_EKS_LoadBalancer" {
  type              = "ingress"
  description       = "Allow HTTPS from Public Internet"
  to_port           = 443
  from_port         = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.EKS_LoadBalancer.id
}

resource "aws_security_group_rule" "HTTP_PublicInternet_EKS_LoadBalancer" {
  type              = "ingress"
  description       = "Allow HTTP from Public Internet"
  to_port           = 80
  from_port         = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.EKS_LoadBalancer.id
}

# Kubernetes will use dynamic ports so we need a rule that supports any port for the health checks of the target groups

resource "aws_security_group_rule" "AllowAll_EKS_LoadBalancer" {
  type                     = "ingress"
  description              = "Allow All Traffic from EKS LoadBalancer Security Group"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.EKS_LoadBalancer.id
  security_group_id        = aws_security_group.EKS_SecurityGroup.id
}


output "EKS_LoadBalancer_SecurityGroup" {
  value = aws_security_group.EKS_LoadBalancer.id
}
