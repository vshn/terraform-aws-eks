locals {
  vpc_name        = var.vpc_name != "" ? var.vpc_name : "${var.cluster_name}-vpc"
  private_subnets = var.private_subnets != null ? var.private_subnets : [for k, v in var.azs : cidrsubnet(var.vpc_cidr, 4, k)]
  public_subnets  = var.public_subnets != null ? var.public_subnets : [for k, v in var.azs : cidrsubnet(var.vpc_cidr, 8, k + 48)]
  intra_subnets   = var.intra_subnets != null ? var.intra_subnets : [for k, v in var.azs : cidrsubnet(var.vpc_cidr, 8, k + 52)]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = local.vpc_name
  cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets
  intra_subnets   = local.intra_subnets

  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway
  enable_dns_hostnames = var.enable_dns_hostnames

  enable_flow_log                      = var.enable_flow_log
  create_flow_log_cloudwatch_iam_role  = var.create_flow_log_cloudwatch_iam_role
  create_flow_log_cloudwatch_log_group = var.create_flow_log_cloudwatch_log_group

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  map_public_ip_on_launch       = var.map_public_ip_on_launch
  manage_default_security_group = var.manage_default_security_group
  manage_default_route_table    = var.manage_default_route_table
  manage_default_network_acl    = var.manage_default_network_acl
}

module "endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "5.0.0"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [module.vpc.default_security_group_id]

  endpoints = {
    s3 = {
      service = "s3"
      tags    = { Name = "s3-vpc-endpoint" }
    }
  }
}
