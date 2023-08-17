output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = <<-EOT
    export KUBECONFIG="/tmp/${module.eks.cluster_name}"
    aws eks --region ${local.region} update-kubeconfig --name ${module.eks.cluster_name}
  EOT
}

output "configure_argocd" {
  description = "Terminal Setup"
  value       = <<-EOT
    export KUBECONFIG="/tmp/${module.eks.cluster_name}"
    aws eks --region ${local.region} update-kubeconfig --name ${module.eks.cluster_name}
    export ARGOCD_OPTS="--port-forward --port-forward-namespace argocd --grpc-web"
    kubectl config set-context --current --namespace argocd
    argocd login --port-forward --username admin --password $(argocd admin initial-password | head -1)
    echo "ArgoCD Username: admin"
    echo "ArgoCD Password: $(kubectl get secrets argocd-initial-admin-secret -n argocd --template="{{index .data.password | base64decode}}")"
    kubectl port-forward -n argocd svc/argo-cd-argocd-server 8080:80
    EOT
}

output "access_argocd" {
  description = "ArgoCD Access"
  value       = <<-EOT
    export KUBECONFIG="/tmp/${module.eks.cluster_name}"
    aws eks --region ${local.region} update-kubeconfig --name ${module.eks.cluster_name}
    echo "ArgoCD URL: https://$(kubectl get ing -n argocd argo-cd-argocd-server -o jsonpath='{.spec.tls[0].hosts[0]}')"
    echo "ArgoCD Username: admin"
    echo "ArgoCD Password: $(kubectl get secrets argocd-initial-admin-secret -n argocd --template="{{index .data.password | base64decode}}")"
    EOT
}

