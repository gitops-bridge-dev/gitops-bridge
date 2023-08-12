
locals {

  argocd_labels = merge ({
    cluster_name = var.cluster_name
    environment  = var.environment
    enable_argocd = true
    "argocd.argoproj.io/secret-type" = "cluster"
  },
  var.addons
  )
  argocd_annotations = merge(
    {
      cluster_name = var.cluster_name
      environment  = var.environment
    },
    var.metadata
  )
  fluxcd_data = merge(
    {
      cluster_name = var.cluster_name
      environment  = var.environment
    },
    var.metadata
  )
}

locals {
  argocd_server_config = <<-EOT
    {
      "tlsClientConfig": {
        "insecure": false
      }
    }
  EOT
  argocd = {
        apiVersion = "v1"
        kind = "Secret"
        metadata = {
          name = try(var.argocd.secret_name,var.cluster_name)
          namespace = try(var.argocd.secret_namespace,"argocd")
          annotations = local.argocd_annotations
          labels = local.argocd_labels
        }
        stringData = {
            name = var.cluster_name
            server = try(var.argocd.server,"https://kubernetes.default.svc")
            config = try(var.argocd.argocd_server_config,local.argocd_server_config)
        }
  }
}

locals {
  fluxcd = {
        apiVersion = "v1"
        kind = "ConfigMap"
        metadata = {
          name = try(var.fluxcd.configmap_name,var.cluster_name)
          namespace = try(var.fluxcd.configmap_namespace,"flux-system")
        }
        data = local.fluxcd_data
  }
}