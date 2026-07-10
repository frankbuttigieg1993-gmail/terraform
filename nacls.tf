####################################         Private NACL                         ####################################

resource "aws_network_acl" "private_subnets_nacl" {
  vpc_id     = module.vpc.vpc_id
  subnet_ids = aws_subnet.private.*.id
  tags = {
    Name = "NACL for Private Subnets"
  }
}

resource "aws_network_acl_rule" "allow_all_outbound" {
  network_acl_id = aws_network_acl.private_subnets_nacl.id
  rule_number    = 130
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "Allow_All" {
  network_acl_id = aws_network_acl.private_subnets_nacl.id
  rule_number    = 1000
  egress         = false
  protocol       = "all"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}


####################################         Public NACL                         ####################################

resource "aws_network_acl" "public_subnets_nacl" {
  vpc_id     = module.vpc.vpc_id
  subnet_ids = aws_subnet.public.*.id
  tags = {
    Name = "NACL for Public Subnets"
  }
}

resource "aws_network_acl_rule" "public_Allow_All" {
  network_acl_id = aws_network_acl.public_subnets_nacl.id
  rule_number    = 1000
  egress         = false
  protocol       = "all"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "public_allow_all_outbound" {
  network_acl_id = aws_network_acl.public_subnets_nacl.id
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}
