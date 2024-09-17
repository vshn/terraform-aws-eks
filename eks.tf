
locals {
  vpc_id              = try(module.vpc[0].vpc_id, var.vpc_id, null)
  private_subnet_ids  = try(module.vpc[0].private_subnets, var.private_subnets_ids, null)
  intra_subnet_ids    = try(module.vpc[0].intra_subnets, var.intra_subnets_ids, null)
  data_private_subnet = try(data.aws_subnets.private_internal_vpc, data.aws_subnets.private_external_vpc, null)
  eks_managed_node_groups_with_worker_az = {
    for key, node_group in var.eks_managed_node_groups :
    key => node_group if contains(keys(node_group), "worker_availability_zones")
  }

  eks_managed_node_groups_with_subnet_ids = {
    for key, node_group in local.eks_managed_node_groups_with_worker_az :
    key => merge(node_group, { "subnet_ids" = local.data_private_subnet[key].ids })
  }

  eks_managed_node_groups = merge(var.eks_managed_node_groups, local.eks_managed_node_groups_with_subnet_ids)
}

# Subnet IDs when VPC is created with this module
data "aws_subnets" "private_internal_vpc" {
  for_each = {
    for k, v in local.eks_managed_node_groups_with_worker_az : k => v
  }
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
  filter {
    name   = "availability-zone"
    values = each.value.worker_availability_zones
  }
  filter {
    name   = "cidr-block"
    values = var.private_subnets
  }
  depends_on = [
    module.vpc[0]
  ]
}

# SubnetIDs if VPC is provided externally
data "aws_subnets" "private_external_vpc" {
  for_each = {
    for k, v in local.eks_managed_node_groups_with_worker_az : k => v
    if !var.enable_eks_vpc # This checks runs only if the vpc is enabled
  }
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
  filter {
    name   = "availability-zone"
    values = each.value.worker_availability_zones
  }
  filter {
    name   = "cidr-block"
    values = var.private_subnets
  }
}


module "cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.24.1"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_private_access      = var.cluster_endpoint_private_access
  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  cluster_security_group_additional_rules = var.cluster_security_group_additional_rules
  node_security_group_additional_rules    = var.node_security_group_additional_rules

  enable_irsa               = true
  create_kms_key            = var.create_kms_key
  cluster_encryption_config = {} # This disables secret encryption
  cluster_addons = {
    coredns = {
      addon_version = var.addon_version_coredns

      timeouts = {
        create = "25m"
        delete = "10m"
      }
    }
    kube-proxy = {
      addon_version = var.addon_version_kube_proxy
    }
    vpc-cni = {
      addon_version        = var.addon_version_vpc_cni
      configuration_values = jsonencode(var.addon_version_vpc_cni_configuration_values)
    }
  }

  vpc_id                   = local.vpc_id
  subnet_ids               = local.private_subnet_ids
  control_plane_subnet_ids = local.intra_subnet_ids
  eks_managed_node_group_defaults = {
    disk_size                  = var.node_group_defaults_disk_size
    instance_types             = var.node_group_defaults_instance_types
    enable_bootstrap_user_data = true
    bootstrap_extra_args       = "--kubelet-extra-args \"${join(" ", var.node_group_defaults_kubelet_args)}\""
    capacity_type              = "ON_DEMAND"
  }
  eks_managed_node_groups = local.eks_managed_node_groups # use the manipulated local variable here. 

  cluster_enabled_log_types              = var.cluster_enabled_log_types
  cloudwatch_log_group_retention_in_days = var.cluster_log_retention

  prefix_separator                   = ""
  cluster_security_group_description = "EKS cluster security group."

  kms_key_enable_default_policy = false
}

module "cluster_auth" {
  source                    = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version                   = "20.24.1"
  manage_aws_auth_configmap = true
  aws_auth_users            = var.aws_auth_users
  aws_auth_roles            = var.aws_auth_roles
}
