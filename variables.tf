variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
  default     = ""
}

variable "enable_eks_vpc" {
  description = "This enables the VPC in the module-aws-eks"
  type        = bool
  default     = true
}

variable "private_subnets" {
  description = "The private subnets to use for the VPC (Node Subnet)"
  type        = list(string)
  default     = null
}

variable "private_subnets_ids" {
  description = "The private subnet ID from the VPC (Node Subnet)"
  type        = list(string)
  default     = null
}

variable "public_subnets" {
  description = "The public subnets to use for the VPC (Nat Gateway)"
  type        = list(string)
  default     = null
}

variable "intra_subnets" {
  description = "The intra subnets to use for the VPC (Control Plane)"
  type        = list(string)
  default     = null
}

variable "intra_subnets_ids" {
  description = "The intra subnet ID from the VPC (Control Plane)"
  type        = list(string)
  default     = null
}

variable "cluster_version" {
  description = "The version of the EKS cluster (major.minor)"
  type        = string
}

variable "cluster_endpoint_private_access" {
  description = "Whether to enable private access to the EKS cluster endpoint"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "Whether to enable public access to the EKS cluster endpoint"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "The CIDR blocks to allow access to the EKS cluster endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "addon_version_vpc_cni_configuration_values" {
  description = "The configuration values for the VPC CNI plugin"
  type        = map(any)
  default     = {}
}

variable "node_group_defaults_kubelet_args" {
  description = "The kubelet arguments to use for the EKS worker nodes"
  type        = list(string)
  default     = []
}

variable "node_group_defaults_instance_types" {
  description = "The instance types to use for the EKS worker nodes"
  type        = list(string)
  default     = []
}

variable "node_group_defaults_disk_size" {
  description = "The disk size (in GB) to use for the EKS worker nodes"
  type        = number
  default     = 100
}

variable "node_group_defaults_node_repair_config" {
  description = "The node auto repair configuration for the node group"
  type = object({
    enabled = bool
  })
  default = null
}

variable "eks_managed_node_groups" {
  description = "Map of EKS managed node group definitions to create"
  type        = any
  default     = {}
}

variable "cluster_log_retention" {
  description = "The number of days to retain the EKS cluster logs"
  type        = number
  default     = 7
}

variable "cluster_enabled_log_types" {
  description = "The types of logs sent to Cloudwatch"
  type        = list(any)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.220.0.0/16"
}

variable "secondary_cidr_blocks" {
  description = "Secondary CIDR blocks for the VPC"
  type        = list(string)
  default     = []
}

variable "azs" {
  description = "The availability zones to use for the VPC"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "enable_nat_gateway" {
  description = "Whether to enable NAT gateways for the VPC"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Whether to use a single NAT gateway for the VPC"
  type        = bool
  default     = false
}

variable "enable_dns_hostnames" {
  description = "Whether to enable DNS hostnames for the VPC"
  type        = bool
  default     = true
}

variable "enable_flow_log" {
  description = "Whether to enable flow logs for the VPC"
  type        = bool
  default     = false
}

variable "enable_ipv6" {
  description = "Whether to enable IPv6 for VPC. Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC"
  type        = bool
  default     = false
}

variable "create_flow_log_cloudwatch_iam_role" {
  description = "Whether to create the IAM role for the flow log"
  type        = bool
  default     = true
}

variable "create_flow_log_cloudwatch_log_group" {
  description = "Whether to create the CloudWatch log group for the flow log"
  type        = string
  default     = true
}

variable "map_public_ip_on_launch" {
  description = "Specify true to indicate that instances launched into the subnet should be assigned a public IP address."
  type        = bool
  default     = true
}

variable "manage_default_security_group" {
  description = "Whether to manage the default security group for the VPC"
  type        = bool
  default     = false
}

variable "manage_default_route_table" {
  description = "Whether to manage the default route table for the VPC"
  type        = bool
  default     = false
}

variable "manage_default_network_acl" {
  description = "Whether to manage the default network ACL for the VPC"
  type        = bool
  default     = false
}

variable "addon_version_vpc_cni" {
  description = "EKS Addon version for VPC-CNI"
  type        = string
}

variable "addon_version_kube_proxy" {
  description = "EKS Addon version for kube-proxy"
  type        = string
}

variable "addon_version_coredns" {
  description = "EKS Addon version for coredns"
  type        = string
}

variable "create_kms_key" {
  description = "Controls if a KMS key for cluster encryption should be created"
  type        = bool
  default     = false
}

variable "aws_auth_users" {
  description = "List of user maps to add to the aws-auth configmap"
  type        = list(any)
  default     = []
}

variable "aws_auth_roles" {
  description = "List of role maps to add to the aws-auth configmap"
  type        = list(any)
  default     = []
}

variable "cluster_security_group_additional_rules" {
  description = "List of additional security group rules to add to the cluster security group created. Set `source_node_security_group = true` inside rules to set the `node_security_group` as source"
  type        = any
  default     = {}
}

variable "node_security_group_additional_rules" {
  description = "List of additional security group rules to add to the node security group created. Set `source_cluster_security_group = true` inside rules to set the `cluster_security_group` as source"
  type        = any
  default     = {}
}

variable "additional_addons" {
  description = "Map of additional addons"
  type        = any
  default     = {}
}

variable "node_group_defaults_iam_role_policies" {
  description = "Policies to attach to every MNG IAM role"
  type        = map(string)
  default     = {}
}
