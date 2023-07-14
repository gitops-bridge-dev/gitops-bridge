output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${local.region} update-kubeconfig --name ${module.eks.cluster_name}"
}


output "terminal_setup" {
  description = "Terminal Setup"
  value       = <<-EOT
    export KUBECONFIG=${local.kubeconfig}
    aws eks --region ${local.region} update-kubeconfig --name ${module.eks.cluster_name}
    export ARGOCD_OPTS="--port-forward --port-forward-namespace argocd --grpc-web"
    kubectl config set-context --current --namespace argocd
    argocd admin dashboard --port 8080
    EOT
}
