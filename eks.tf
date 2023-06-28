module "cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.12.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_private_access      = var.cluster_endpoint_private_access
  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  enable_irsa    = true
  create_kms_key = var.create_kms_key
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

  eks_managed_node_groups = merge(
    {
      default_node_group = {
        ami_id                     = var.ami_id
        enable_bootstrap_user_data = true

        bootstrap_extra_args = "--kubelet-extra-args \"${join(" ", var.kubelet_args)}\""

        instance_types = var.instance_types
        capacity_type  = "ON_DEMAND"

        min_size     = var.min_size
        max_size     = var.max_size
        desired_size = var.desired_size

        disk_size = var.disk_size
      }
    },
    var.additional_node_groups
  )

  cluster_enabled_log_types              = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  cloudwatch_log_group_retention_in_days = var.cluster_log_retention

  prefix_separator                   = ""
  cluster_security_group_description = "EKS cluster security group."
}
