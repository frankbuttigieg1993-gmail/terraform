####################################################### EKS IAM ##########################################################################

resource "aws_iam_role" "EKS_Cluster" {
  name = "EKS_Cluster_Role"
  assume_role_policy = file("${path.module}/templates/iam/ec2-assumerole-policy.json")
}

output "EKS-Cluster-Role_Arn" {
  value = aws_iam_role.EKS_Cluster.arn
}

resource "aws_iam_instance_profile" "EKS_Instance_Profile" {
  name = "EKS_Cluster_InstanceProfile"
  role = aws_iam_role.EKS_Cluster.name
}

resource "aws_iam_policy" "EKS_Cluster_Policy" {
  name        = "EKS_Cluster_Policy"
  description = "EKS Cluster Policy"
  policy = templatefile("${path.module}/templates/iam/EKS/EKS_Cluster_Policy.json", {account_id = var.account_id})
}

resource "aws_iam_policy_attachment" "EKS_Cluster_Policy_Attachment" {
  name       = "EKS Cluster Policy Attachment"
  roles      = [aws_iam_role.EKS_Cluster.name]
  policy_arn = aws_iam_policy.EKS_Cluster_Policy.arn
}

resource "aws_iam_policy_attachment" "EKS_AmazonEKSWorkerNodePolicy_Managed_Policy_Attachment" {
lifecycle {
    ignore_changes = [roles]
  }
  name       = "EKS Cluster AmazonEKSWorkerNodePolicy Managed Policy Attachment"
  roles      = [aws_iam_role.EKS_Cluster.name, aws_iam_role.EKS_Developer.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_policy_attachment" "EKS_AmazonSSMManagedInstanceCore_Managed_Policy_Attachment" {
  name       = "EKS Cluster AmazonSSMManagedInstanceCore Managed Policy Attachment"
  roles      = [aws_iam_role.EKS_Cluster.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy_attachment" "EKS_AmazonEC2ContainerRegistryReadOnly_Managed_Policy_Attachment" {
  name       = "EKS Cluster AmazonEC2ContainerRegistryReadOnly Managed Policy Attachment"
  roles      = [aws_iam_role.EKS_Cluster.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_policy_attachment" "EKS_CNI_Managed_Policy_Attachment" {
# EKS will create roles and associate it with these policies after it runs. This will be seen as a difference in Terraform that we don't want to remove
# This LifeCycle Configuration will allow Terraform to create the resource on the 1st run but ignore it during the state assessment on subsequent runs. 
lifecycle {
    ignore_changes = [roles]
  }
  name       = "EKS Cluster AmazonEKS_CNI_Policy Managed Policy Attachment"
  roles      = [aws_iam_role.EKS_Cluster.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_policy_attachment" "EKS_AmazonEKSClusterPolicy_Policy_Attachment" {
# EKS will create roles and associate it with these policies after it runs. This will be seen as a difference in Terraform that we don't want to remove
# This LifeCycle Configuration will allow Terraform to create the resource on the 1st run but ignore it during the state assessment on subsequent runs. 
lifecycle {
    ignore_changes = [roles]
  }
  name       = "EKS Cluster AmazonEKSClusterPolicy Managed Policy Attachment"
  roles      = [aws_iam_role.EKS_Cluster.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_policy" "EKS_Cluster_ALB_Policy" {
  name        = "EKS_AWSLoadBalancerControllerIAMPolicy"
  description = "EKS AWSLoadBalancerControllerIAMPolicy"
  policy = templatefile("${path.module}/templates/iam/EKS/AWSLoadBalancerControllerIAMPolicy.json", {})
}

resource "aws_iam_policy_attachment" "EKS_ALB_Policy_Attachment" {
  name       = "EKS AWSLoadBalancerControllerIAMPolicy Attachment"
  roles      = [aws_iam_role.EKS_Cluster.name]
  policy_arn = aws_iam_policy.EKS_Cluster_Policy.arn
}

resource "aws_iam_policy_attachment" "EKS_SSM_ReadOnly_Attachment" {
  name       = "EKS Cluster SSM Read Only Policy Attachment"
  roles      = [aws_iam_role.EKS_Cluster.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "EKS_CloudWatchAgentServerPolicy_Attachment" {
  name       = "EKS Cluster CloudWatchAgentServerPolicy Policy Attachment"
  roles      = [aws_iam_role.EKS_Cluster.name]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role" "EKS_Developer" {
  name = "EKS_Developer"
  assume_role_policy = templatefile("${path.module}/templates/iam/EKS/EKS-Developer-assumerole-policy.json", {account_id = var.account_id})
}

####################################################### EKS Security Groups ##########################################################################

resource "aws_security_group" "EKS_SecurityGroup" {
  name = "EKS Security Group"
  description = "EKS Security Group"
  vpc_id      = module.vpc.vpc_id
   tags = {
     Name = "EKS Security Group"
          }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "EKS_Allow_All" {
  type               = "ingress"
  description        = "Allow EKS nodes to communicate with each other"
  from_port          = 0
  to_port            = 0
  protocol           =  "-1"
  source_security_group_id  = aws_security_group.EKS_SecurityGroup.id
  security_group_id  = aws_security_group.EKS_SecurityGroup.id
}

resource "aws_security_group_rule" "EKS_Allow_SSH_VPN" {
  type               = "ingress"
  description        = "Allow SSH access from VPN"
  to_port            = 22
  from_port          = 22
  protocol           =  "tcp"
  cidr_blocks        = ["10.0.0.0/16"]
  security_group_id  = aws_security_group.EKS_SecurityGroup.id
}

resource "aws_security_group_rule" "EKS_Allow_SSH_SharedResources" {
  type               = "ingress"
  description        = "Allow SSH access from SharedResources"
  to_port            = 22
  from_port          = 22
  protocol           =  "tcp"
  cidr_blocks        = ["10.1.0.0/16"]
  security_group_id  = aws_security_group.EKS_SecurityGroup.id
}

resource "aws_security_group_rule" "EKS_Allow_HTTPs_VPN" {
  type               = "ingress"
  description        = "Allow HTTPS access from the VPN"
  to_port            = 443
  from_port          = 443
  protocol           =  "tcp"
  cidr_blocks        = ["10.0.0.0/16"]
  security_group_id  = aws_security_group.EKS_SecurityGroup.id
}

resource "aws_security_group_rule" "EKS_Allow_HTTPs_SharedResources" {
  type               = "ingress"
  description        = "Allow HTTPS access from the VPN"
  to_port            = 443
  from_port          = 443
  protocol           =  "tcp"
  cidr_blocks        = ["10.1.0.0/16"]
  security_group_id  = aws_security_group.EKS_SecurityGroup.id
}

# Kubernetes will use dynamic ports so we need a rule that supports any port for the health checks of the target groups

resource "aws_security_group_rule" "EKS_LB_Allow_EKSCluster" {
  type               = "ingress"
  description        = "Allow All Traffic from EKS LoadBalancer Security Group"
  from_port          = 0
  to_port            = 0
  protocol           =  "-1"
  source_security_group_id  = aws_security_group.EKS_LB_SecurityGroup.id
  security_group_id  = aws_security_group.EKS_SecurityGroup.id
}

# #### Only Required for NLBs

# resource "aws_security_group_rule" "EKS_Allow_Local" {
#   type               = "ingress"
#   description        = "Allow All Local Traffic"
#   from_port          = 0
#   to_port            = 0
#   protocol           =  "-1"
#   cidr_blocks        = ["10.3.0.0/16"]
#   security_group_id  = aws_security_group.EKS_SecurityGroup.id
# }

# resource "aws_security_group_rule" "EKS_Allow_Shared" {
#   type               = "ingress"
#   description        = "Allow All Shared Traffic"
#   from_port          = 0
#   to_port            = 0
#   protocol           =  "-1"
#   cidr_blocks        = ["10.1.0.0/16"]
#   security_group_id  = aws_security_group.EKS_SecurityGroup.id
# }


# resource "aws_security_group_rule" "EKS_Allow_Management" {
#   type               = "ingress"
#   description        = "Allow All Management Traffic"
#   from_port          = 0
#   to_port            = 0
#   protocol           =  "-1"
#   cidr_blocks        = ["10.0.0.0/16"]
#   security_group_id  = aws_security_group.EKS_SecurityGroup.id
# }

  output "EKS_SecurityGroup" {
  value = aws_security_group.EKS_SecurityGroup.id
}

####################################################### EKS  Groups ##########################################################################

resource "aws_security_group" "EKS_LB_SecurityGroup" {
  name = "EKS LB Security Group"
  description = "EKS LB Security Group"
  vpc_id      = module.vpc.vpc_id
   tags = {
     Name = "EKS LB Security Group"
          }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "EKS_LB_Allow_HTTPS_Local" {
  type               = "ingress"
  description        = "Allow Local HTTPS"
  to_port            = 443
  from_port          = 443
  protocol           =  "tcp"
  cidr_blocks        = ["10.2.0.0/16"]
  security_group_id  = aws_security_group.EKS_LB_SecurityGroup.id
}

resource "aws_security_group_rule" "EKS_LB_Allow_HTTPS_Shared" {
  type               = "ingress"
  description        = "Allow HTTPS from Shared Resources Account"
  to_port            = 443
  from_port          = 443
  protocol           =  "tcp"
  cidr_blocks        = ["10.1.0.0/16"]
  security_group_id  = aws_security_group.EKS_LB_SecurityGroup.id
}

resource "aws_security_group_rule" "EKS_LB_Allow_HTTPS_Management" {
  type               = "ingress"
  description        = "Allow HTTPS from Management Account"
  to_port            = 443
  from_port          = 443
  protocol           =  "tcp"
  cidr_blocks        = ["10.0.0.0/16"]
  security_group_id  = aws_security_group.EKS_LB_SecurityGroup.id
}