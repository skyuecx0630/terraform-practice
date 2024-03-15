locals {
  public_subnets  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 4, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 4, k + 2)]

  public_subnet_names  = [for k, v in local.azs : "${var.resource_name_tag_perfix}-public-subnet-${v}"]
  private_subnet_names = [for k, v in local.azs : "${var.resource_name_tag_perfix}-private-subnet-${v}"]

  azs = slice(data.aws_availability_zones.available.names, 0, 2)
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.resource_name_tag_perfix}-vpc"
  cidr = var.vpc_cidr

  azs                  = local.azs
  public_subnets       = local.public_subnets
  private_subnets      = local.private_subnets
  public_subnet_names  = local.public_subnet_names
  private_subnet_names = local.private_subnet_names

  enable_nat_gateway   = true
  create_igw           = true
  enable_dns_hostnames = true
}
