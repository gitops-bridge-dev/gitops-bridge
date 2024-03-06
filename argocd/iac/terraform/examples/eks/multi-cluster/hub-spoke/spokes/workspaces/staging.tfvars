vpc_cidr = "10.2.0.0/16"
region = "us-west-2"
kubernetes_version = "1.29"
addons = {
  enable_aws_load_balancer_controller = true
  enable_metrics_server               = true
  # Disable argocd on spoke clusters
  enable_argocd = false
}