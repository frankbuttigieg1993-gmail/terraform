##[root@localhost internal_project]# terraform state show 'aws_instance.bastion'

output "VPC_id" {
  value = module.vpc.vpc_id
}

output "VPC_Name" {
  value = module.vpc.name
}

output "vpc_arn" {
  value = module.vpc.vpc_arn
}

output "vpc_main_route_table_id" {
  value = module.vpc.vpc_main_route_table_id
}

output "Private_Subnet_IDs" {
  value = aws_subnet.private.*.id
}

output "Public_Subnet_IDs" {
  value = aws_subnet.public.*.id
}