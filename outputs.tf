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
