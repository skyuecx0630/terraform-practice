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

module "alb_sg" {
  source = "terraform-aws-modules/security-group/aws"

  vpc_id = module.vpc.vpc_id
  name   = "${var.resource_name_tag_perfix}-alb-sg"

  ingress_with_cidr_blocks = [
    {
      rule        = "http-80-tcp",
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  computed_egress_with_source_security_group_id = [
    {
      rule                     = "http-8080-tcp"
      source_security_group_id = module.application_sg.security_group_id
    }
  ]

  number_of_computed_egress_with_source_security_group_id = 1
}

module "application_sg" {
  source = "terraform-aws-modules/security-group/aws"

  vpc_id = module.vpc.vpc_id
  name   = "${var.resource_name_tag_perfix}-application-sg"

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-8080-tcp"
      source_security_group_id = module.alb_sg.security_group_id
    }
  ]

  egress_with_cidr_blocks = [{
    rule        = "all-all"
    cidr_blocks = "0.0.0.0/0"
  }]

  number_of_computed_ingress_with_source_security_group_id = 1
}
