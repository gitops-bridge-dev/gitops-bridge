output "configure_kubectl_hub" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${local.region} update-kubeconfig --name ${module.eks_hub.cluster_name}"
}

output "terminal_setup_hub" {
  description = "Terminal Setup"
  value       = <<-EOT
    export KUBECONFIG="/tmp/${module.eks_hub.cluster_name}"
    aws eks --region ${local.region} update-kubeconfig --name ${module.eks_hub.cluster_name}
    export ARGOCD_OPTS="--port-forward --port-forward-namespace argocd --grpc-web"
    kubectl config set-context --current --namespace argocd
    argocd admin dashboard --port 8080
    EOT
}

output "configure_kubectl_spoke_staging" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${local.region} update-kubeconfig --name ${module.eks_spoke_staging.cluster_name}"
}

output "terminal_setup_staging" {
  description = "Terminal Setup"
  value       = <<-EOT
    export KUBECONFIG="/tmp/${module.eks_spoke_staging.cluster_name}"
    aws eks --region ${local.region} update-kubeconfig --name ${module.eks_spoke_staging.cluster_name}
    EOT
}

output "configure_kubectl_spoke_prod" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${local.region} update-kubeconfig --name ${module.eks_spoke_prod.cluster_name}"
}

output "terminal_setup_prod" {
  description = "Terminal Setup"
  value       = <<-EOT
    export KUBECONFIG="/tmp/${module.eks_spoke_prod.cluster_name}"
    aws eks --region ${local.region} update-kubeconfig --name ${module.eks_spoke_prod.cluster_name}
    EOT
}

