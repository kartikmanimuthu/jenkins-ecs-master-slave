##################################################################################
# VPC & Network Resources
##################################################################################

module "vpc" {
  source = "git::git@bitbucket.org:rohitahuja1/core-tf-mod-vpc.git?ref=v1.0.8"

  name = local.project_name

  vpc_cidr                = var.vpc_cidr
  no_of_azs               = 2
  vpc_endpoints           = []
  create_database_subnets = var.create_database_subnets
  create_intra_subnets    = var.create_intra_subnets
  enable_nat_gateway      = var.enable_nat_gateway

  tags = local.tags
}

output "vpc_details" {
  description = "All details of the VPC"
  value       = module.vpc.vpc_details
}

# # Self managed NAT instances
# module "ec2_managed_nat" {
#   for_each               = { for idx, subnet_id in module.vpc.public_subnets : idx => subnet_id }
#   source                 = "git::git@bitbucket.org:rohitahuja1/core-tf-mod-managed-nat?ref=v1.0.1"
#   name                   = local.project_name
#   custom_ami_id          = "ami-06031e2c49c278c8f" # Amazon Linux 2 AMI (64-bit (x86))
#   vpc_id                 = module.vpc.vpc_id
#   private_route_table_id = module.vpc.private_route_table_ids[each.key]
#   public_subnet_id       = each.value
#   tags                   = local.tags
# }

# output "ec2_nat_details" {
#   description = "Details of the NAT instances"
#   value = { for idx, nat in module.ec2_managed_nat : idx => {
#     nat_instance_id   = nat.nat_instance_id
#     nat_instance_name = nat.nat_instance_name
#     nat_eip_address   = nat.nat_eip_address
#   } }
# }
