data "aws_region" "current" {}

locals {

  cluster_config = merge ({
    enable_argocd = var.enable_argocd
    cluster_name = var.cluster_name,
    environment  = var.environment
  },
  var.metadata,
  var.addons
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
          name = try(var.options.argocd.secret_name,var.cluster_name)
          namespace = try(var.options.argocd.secret_namespace,"argocd")
          annotations = {for key, value in local.cluster_config : key => tostring(value) if value != null}
          labels = merge({
            for key, value in
            {
              for key, value in local.cluster_config : key => tostring(value) if value != null
            } :
            key => tostring(value) if startswith(key, "metadata_") == false
          },{
            "argocd.argoproj.io/secret-type" = "cluster"
          })


        }
        stringData = {
            name = var.cluster_name
            server = try(var.options.argocd.server,"https://kubernetes.default.svc")
            config = local.argocd_server_config
        }
  }
}

locals {
  fluxcd = {
        apiVersion = "v1"
        kind = "ConfigMap"
        metadata = {
          name = try(var.options.fluxcd.configmap_name,var.cluster_name)
          namespace = try(var.options.fluxcd.configmap_namespace,"flux-system")
        }
        data = {for key, value in local.cluster_config : key => tostring(value) if value != null}
  }
}