output "kubeconfig" {
  value = <<-EOT
    apiVersion: v1
    clusters:
    - cluster:
        certificate-authority-data: ${module.cluster.cluster_certificate_authority_data}
        server: ${module.cluster.cluster_endpoint}
      name: ${var.cluster_name}
    contexts:
    - context:
        cluster: ${var.cluster_name}
        user: ${var.cluster_name}
      name: ${var.cluster_name}
    current-context: ${var.cluster_name}
    kind: Config
    preferences: {}
    users:
    - name: ${var.cluster_name}
      user:
        exec:
          apiVersion: client.authentication.k8s.io/v1beta1
          args:
          - token
          - --cluster-id
          - ${var.cluster_name}
          command: aws-iam-authenticator
  EOT
}

# EKS
output "oidc_provider_arn" {
  value = module.cluster.oidc_provider_arn
}
output "cluster_oidc_issuer_url" {
  value = module.cluster.cluster_oidc_issuer_url
}

output "node_security_group_id" {
  value = module.cluster.node_security_group_id
}

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = module.cluster.cluster_endpoint
}


output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.cluster.cluster_certificate_authority_data
}

# eks-managed-node-group
output "node_iam_role_name" {
  description = "The name of the Node IAM role"
  value       = module.cluster.eks_managed_node_groups.iam_role_name
}

# VPC
output "vpc_id" {
  value = module.vpc.vpc_id
}
output "private_route_table_ids" {
  value = module.vpc.private_route_table_ids
}
output "private_subnets" {
  value = module.vpc.private_subnets
}
output "public_subnets" {
  value = module.vpc.public_subnets
}
