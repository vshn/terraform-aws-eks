
locals {
  eks_managed_node_groups_with_worker_az = {
    for key, node_group in var.eks_managed_node_groups :
    key => node_group if contains(keys(node_group), "worker_availability_zones")
  }

  eks_managed_node_groups_with_subnet_ids = {
    for key, node_group in local.eks_managed_node_groups_with_worker_az :
    key => merge(node_group, { "subnet_ids" = data.aws_subnets.private[key].ids })
  }

  eks_managed_node_groups = merge(var.eks_managed_node_groups, local.eks_managed_node_groups_with_subnet_ids)
}


data "aws_subnets" "private" {
  for_each = { for k, v in local.eks_managed_node_groups_with_worker_az : k => v }
  filter {
    name   = "vpc-id"
    values = [module.vpc.vpc_id]
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
    module.vpc
  ]
}

module "cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.16.0"

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

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets
  eks_managed_node_group_defaults = {
    disk_size                  = var.node_group_defaults_disk_size
    instance_types             = var.node_group_defaults_instance_types
    enable_bootstrap_user_data = true
    bootstrap_extra_args       = "--kubelet-extra-args \"${join(" ", var.node_group_defaults_kubelet_args)}\""
    capacity_type              = "ON_DEMAND"
  }
  eks_managed_node_groups = local.eks_managed_node_groups # use the manipulated local variable here. 

  cluster_enabled_log_types              = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  cloudwatch_log_group_retention_in_days = var.cluster_log_retention

  prefix_separator                   = ""
  cluster_security_group_description = "EKS cluster security group."

  manage_aws_auth_configmap = true
  aws_auth_users            = var.aws_auth_users
  aws_auth_roles            = var.aws_auth_roles
}
