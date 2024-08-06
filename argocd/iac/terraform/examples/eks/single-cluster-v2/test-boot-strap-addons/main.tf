variable "addons" {
  description = "Kubernetes addons"
  type        = any
  default = {
    enable_aws_load_balancer_controller = true
    enable_aws_ebs_csi_resources        = true # generate gp2 and gp3 storage classes for ebs-csi
    enable_metrics_server               = true
    enable_gatekeeper                   = true
    enable_karpenter                   = true
    enable_argocd                       = true
    enable_foobar = true
  }
}

locals {
  addons = var.addons
}

locals {
    appset = templatefile("${path.module}/addons.tpl.yaml", {addons: local.addons})
}

output "appset" {
  value = local.appset
}

