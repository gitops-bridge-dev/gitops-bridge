vpc_cidr = "10.1.0.0/16"
region = "us-west-2"
kubernetes_version = "1.28"
addons = {
  enable_aws_load_balancer_controller = true
  enable_metrics_server               = true
  # Enable argocd on spoke clusters only for workloads, addons are deployed by hub cluster
  enable_argocd = true
}