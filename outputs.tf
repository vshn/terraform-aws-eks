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

output "oidc_provider_arn" {
  value = module.cluster.oidc_provider_arn
}

# VPC
output "vpc_id" {
  value = module.vpc.vpc_id
}
output "private_route_table_ids" {
  value = module.vpc.private_route_table_ids
}
