################################################################################
# Install ArgoCD
################################################################################
resource "helm_release" "argocd" {
  count = var.argocd_create_install ? 1 : 0

  # https://github.com/argoproj/argo-helm/blob/main/charts/argo-cd/Chart.yaml
  # (there is no offical helm chart for argocd)
  name             = try(var.argocd.name, "argo-cd")
  description      = try(var.argocd.description, "A Helm chart to install the ArgoCD")
  namespace        = try(var.argocd.namespace, "argocd")
  create_namespace = try(var.argocd.create_namespace, true)
  chart            = try(var.argocd.chart,"argo-cd")
  version          = try(var.argocd.chart_version, "5.38.0")
  repository       = try(var.argocd.repository, "https://argoproj.github.io/argo-helm")
  values           = try(var.argocd.values, [])

  timeout                    = try(var.argocd.timeout, null)
  repository_key_file        = try(var.argocd.repository_key_file, null)
  repository_cert_file       = try(var.argocd.repository_cert_file, null)
  repository_ca_file         = try(var.argocd.repository_ca_file, null)
  repository_username        = try(var.argocd.repository_username, null)
  repository_password        = try(var.argocd.repository_password, null)
  devel                      = try(var.argocd.devel, null)
  verify                     = try(var.argocd.verify, null)
  keyring                    = try(var.argocd.keyring, null)
  disable_webhooks           = try(var.argocd.disable_webhooks, null)
  reuse_values               = try(var.argocd.reuse_values, null)
  reset_values               = try(var.argocd.reset_values, null)
  force_update               = try(var.argocd.force_update, null)
  recreate_pods              = try(var.argocd.recreate_pods, null)
  cleanup_on_fail            = try(var.argocd.cleanup_on_fail, null)
  max_history                = try(var.argocd.max_history, null)
  atomic                     = try(var.argocd.atomic, null)
  skip_crds                  = try(var.argocd.skip_crds, null)
  render_subchart_notes      = try(var.argocd.render_subchart_notes, null)
  disable_openapi_validation = try(var.argocd.disable_openapi_validation, null)
  wait                       = try(var.argocd.wait, true)
  wait_for_jobs              = try(var.argocd.wait_for_jobs, null)
  dependency_update          = try(var.argocd.dependency_update, null)
  replace                    = try(var.argocd.replace, null)
  lint                       = try(var.argocd.lint, null)

  dynamic "postrender" {
    for_each = length(try(var.argocd.postrender,{})) > 0 ? [var.argocd.postrender] : []

    content {
      binary_path = postrender.value.binary_path
      args        = try(postrender.value.args, null)
    }
  }

  dynamic "set" {
    for_each = try(var.argocd.set,[])

    content {
      name  = set.value.name
      value = set.value.value
      type  = try(set.value.type, null)
    }
  }

  dynamic "set_sensitive" {
    for_each = try(var.argocd.set_sensitive, [])

    content {
      name  = set_sensitive.value.name
      value = set_sensitive.value.value
      type  = try(set_sensitive.value.type, null)
    }
  }

}

/*
################################################################################
# Register ArgoCD Cluster Secret
################################################################################
resource "kubectl_manifest" "cluster" {
  count = var.argocd_cluster != null ? 1 : 0

  yaml_body = yamlencode(var.argocd_cluster)

  depends_on = [ helm_release.argocd ]
}
*/
resource "kubernetes_secret_v1" "cluster" {
  count = var.argocd_cluster != null ? 1 : 0

  metadata {
    name = var.argocd_cluster.metadata.name
    namespace = var.argocd_cluster.metadata.namespace
    annotations = var.argocd_cluster.metadata.annotations
    labels = var.argocd_cluster.metadata.labels
  }
  data = var.argocd_cluster.stringData

}


################################################################################
# Create App of Apps
################################################################################
resource "kubectl_manifest" "bootstrap" {
  for_each = var.argocd_bootstrap_app_of_apps

  yaml_body = each.value

  depends_on = [ resource.kubernetes_secret_v1.cluster ]
}


